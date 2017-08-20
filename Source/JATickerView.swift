/**
 Copyright 2016 Jay Ayres

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation
import UIKit

/**
 UIView subclass representing the digitized ticker
 */
@IBDesignable
@objc open class JATickerView: UIView {
    // MARK: - Private constants
    fileprivate static let kTickerNumDotsY = 8
    fileprivate static let kTickerImageCacheCapacity = 400
    static let kTickerThresholdToRequestMoreData = 60


    // MARK: - Public properties

    /**
     The delegate to feed more content to the ticker
     */
    open weak var delegate: JATickerViewDelegate? {
        didSet {
            self.tickerUtils?.tickerDelegate = delegate
            self.flushCacheOfImagesForLights()
            self.reinitLightsAfterResize(self.frame)
        }
    }

    /**
     How much time in seconds to sleep between ticker ticks
     */
    open var tickDelaySeconds: TimeInterval = 0.16

    /**
     Whether or not the ticker is ticking
     */
    open var isStarted: Bool = false

    // MARK: - Private properties

    /**
     All characters for the ticker that have been fed in so far, including
     ones which have already passed by
     */
    fileprivate var curTickerStr: String = ""

    /**
     UIImageViews for each dot
     */
    fileprivate var imgViews: [[UIImageView]] = []

    /**
     How many dots are present in the view in the x direction
     */
    fileprivate var numDotsX: CGFloat = 0

    /**
     Dimensions of a dot UIImageView
     */
    fileprivate var dotSize: CGSize? = nil

    /**
     Last size of the ticker view
     */
    fileprivate var lastViewSize: CGSize? = nil

    /**
     Dimensions of the source UIImages representing each dot
     */
    fileprivate var dotPixelDimensions: CGSize? = nil

    /**
     Whether or not the ticker view is currently changing its dimensions
     */
    fileprivate var isResizing: Bool = false

    /**
     How much ticker data has been fed already from the client
     */
    fileprivate var fedDataLength: UInt = 0

    /**
     Cache of images for specific positions in the ticker
     */
    fileprivate var imageCache: [String:UIImage] =
        Dictionary<String, UIImage>(minimumCapacity: kTickerImageCacheCapacity)

    /**
     Timer for updating the ticker
     */
    fileprivate var updateTickerTimer: Timer? = nil

    /**
     Current state of the ticker's horizontal scrolling
     */
    fileprivate var currentTickerState: JATickerScrollState?

    /**
     Utility instance
     */
    fileprivate var tickerUtils: JATickerUtils?


    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        initMethod(frame)
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initMethod(CGRect.zero)
    }

    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        let utils = JATickerUtils(loadSymbols: false)
        utils.tickerDelegate = self.delegate
        utils.tickerView = self
        let tickerState = JATickerScrollState(tickerStr: "", dotScrollX: 0, utils: utils)
        let dotRepresentation = tickerState.dotRepresentation()
        drawDotRepresentation(dotRepresentation)
    }

    fileprivate func initMethod(_ frame: CGRect) {
        self.tickerUtils = JATickerUtils()
        self.tickerUtils!.tickerDelegate = self.delegate
        self.tickerUtils!.tickerView = self
        self.flushCacheOfImagesForLights()
        self.reinitLightsAfterResize(frame)
    }

    // MARK: - Public methods

    open override func layoutSubviews() {
        super.layoutSubviews()

        if lastViewSize == nil {
            self.reinitLightsAfterResize(self.frame)
        } else {
            let curSize = self.frame.size
            if curSize.width != lastViewSize!.width || curSize.height != lastViewSize!.height {
                self.reinitLightsAfterResize(self.frame)
            }
        }
    }

    /**
     Tell the ticker to start moving
     */
    open func startTicker() {
        if isStarted {
            return
        }
        isStarted = true

        updateTickerTimer?.invalidate()
        self.advanceAndUpdateTicker()
    }

    /**
     Tell the ticker to stop moving
     */
    open func stopTicker() {
        if !isStarted {
            return
        }

        updateTickerTimer?.invalidate()
        isStarted = false
    }

    /**
     Clear all previously-saved data from the ticker and reset the feed index to 0.
     Stops the ticker if it was started. Client must restart it again to continue.
     */
    open func clearAllDataFromTicker() {
        stopTicker()
        self.fedDataLength = 0
        self.currentTickerState = nil
        self.curTickerStr = ""
    }

    /**
     Instruct the ticker view to ask the delegate again for the images that should
     be used for each light of the ticker. Not necessary to call this unless the
     image for a ticker dot ever changes at runtime.
     */
    open func flushCacheOfImagesForLights() {
        self.imageCache =
            Dictionary<String, UIImage>(minimumCapacity: JATickerView.kTickerImageCacheCapacity)
    }


    // MARK: - Private methods

    fileprivate func loadImageForDot(isOn: Bool, atX xCoord: Int, andY yCoord: Int) -> UIImage? {
        let cacheKey = String(xCoord) + "_" + String(yCoord) + "_" + String(isOn)
        let cachedImage = imageCache[cacheKey]
        if cachedImage != nil {
            return cachedImage!
        }

        guard let utils = self.tickerUtils else {
            return nil
        }

        var image = utils.checkDelegateForDotImage(isOn: isOn,
                                                   xCoord: UInt(xCoord),
                                                   yCoord: UInt(yCoord))

        if image != nil && (image!.size.width != image!.size.height) {
            NSLog("JATickerView illegal state: image at x=" + String(xCoord) +
                  " y=" + String(yCoord) + " must be square but had size (" +
                  String(describing: image!.size.width) + "," +
                  String(describing: image!.size.height) + ").")
            image = nil
        }


        if image == nil {
            image = UIImage.jaTickerViewDefaultDotColorForState(isOn)
        }

        if image == nil {
            return nil
        }

        if self.dotPixelDimensions == nil {
            self.dotPixelDimensions = CGSize(width: image!.size.width, height: image!.size.height)
        } else {
            if self.dotPixelDimensions!.width != image!.size.width ||
               self.dotPixelDimensions!.height != image!.size.height {

                NSLog("JATickerView illegal state: image at x=" +
                      String(xCoord) + " y=" + String(yCoord) +
                      " must be the same pixel dimensions as the image " +
                      "at (0,0). Expected dimensions of (" +
                      String(describing: self.dotPixelDimensions!.width) + "," +
                      String(describing: self.dotPixelDimensions!.height) +
                      ") but got dimensions of (" + String(describing: image!.size.width) + "," +
                      String(describing: image!.size.height) + ").")

                // Ensure that the default image is used when this happens
                image = UIImage.jaTickerViewDefaultDotColorForState(isOn)
            }
        }

        imageCache[cacheKey] = image!
        return image!
    }

    fileprivate func reinitLightsAfterResize(_ frame: CGRect) {
        isResizing = true
        var dotHgt = frame.size.height / CGFloat(JATickerView.kTickerNumDotsY)
        if dotHgt <= 0 {
            dotHgt = 16
        }
        dotSize = CGSize(width: dotHgt, height: dotHgt)
        numDotsX = frame.size.width / dotSize!.width

        let numDotsXInt = Int(numDotsX) + 1

        var leftOffset: CGFloat = 0
        imgViews = []
        for i in 0..<numDotsXInt {
            var colViews: [UIImageView] = []
            var topOffset: CGFloat = 0
            for j in 0..<JATickerView.kTickerNumDotsY {
                let image = loadImageForDot(isOn: false, atX: i, andY: j)
                let v = UIImageView(image: image)
                v.frame = CGRect(x: leftOffset, y: topOffset,
                                 width: dotSize!.width, height: dotSize!.height)
                self.addSubview(v)
                colViews.append(v)
                topOffset += dotSize!.height
            }

            leftOffset += dotSize!.width
            imgViews.append(colViews)
        }
        isResizing = false
        self.lastViewSize = CGSize(width: frame.size.width, height: frame.size.height)
    }

    fileprivate func updateTickerColumn(columnIndex: Int,
                                                xOffInChar: UInt,
                                                chr: JATickerChar?) {
        var colViews = imgViews[columnIndex]
        for j in 1..<(JATickerView.kTickerNumDotsY-1) {
            let v = colViews[j]
            if chr != nil && chr!.shouldLightDot(xCoord: Int(xOffInChar), yCoord: (j-1)) {
                let image = loadImageForDot(isOn: true, atX: columnIndex, andY: (j-1))
                v.image = image
            } else {
                let image = loadImageForDot(isOn: false, atX: columnIndex, andY: (j-1))
                v.image = image
            }
        }
    }

    fileprivate func drawDotRepresentation(_ dots: JATickerDotRepresentation) {
        guard let utils = self.tickerUtils else {
            return
        }
        if isResizing {
            return
        }
        let numDotsXInt = Int(self.numDotsX)
        let dotGrid = dots.dotGrid

        for dotX in 0..<numDotsXInt {
            var curChar: JATickerChar?
            var curCharOffsetX: Int?
            if dotX >= dotGrid.count {
                curChar = utils.lookupDigitizedChar("|")
                curCharOffsetX = 0
            } else {
                let gridAtX = dotGrid[dotX]
                curChar = gridAtX.0
                curCharOffsetX = gridAtX.1
            }

            guard let xOffset = curCharOffsetX else {
                continue
            }
            updateTickerColumn(columnIndex: dotX, xOffInChar: UInt(xOffset), chr: curChar)
        }
    }

    /**
     If the ticker has data, use it. Otherwise, call the delegate method to get more data

     - returns: True if more data has been appended to the end of the ticker
     */
    fileprivate func appendMoreTickerDataToEnd() -> Bool {
        if let data = self.delegate?.tickerView?(self, tickerDataAtEnd: self.fedDataLength),
           let utils = self.tickerUtils {
            if data.characters.count > 0 {
                fedDataLength += UInt(data.characters.count)
                curTickerStr = curTickerStr + utils.formatTickerStringWithMetadata(data)
                return true
            }
        } else {
            NSLog("WARNING: Must implement delegate method tickerDataAtEnd " +
                  "to see data on the ticker")
        }

        return false
    }

    @objc fileprivate func advanceAndUpdateTicker() {
        guard let utils = self.tickerUtils else {
            return
        }
        var nextState: JATickerScrollState?
        if let previousTickerState = self.currentTickerState {
            nextState = previousTickerState.nextState()
        }

        var pendingState = nextState
        if pendingState == nil {
            pendingState = JATickerScrollState(
                tickerStr: self.curTickerStr,
                dotScrollX: 0,
                utils: utils)
        }
        guard var currentState = pendingState else {
            return
        }

        if currentState.readyToAskForMoreData() {
            // Ask for more data
            if self.appendMoreTickerDataToEnd() {
                // Try again to get a state that isn't exceeded the ticker length, else give up
                currentState = JATickerScrollState(
                    tickerStr: self.curTickerStr,
                    dotScrollX: currentState.dotScrollX,
                    utils: utils)
            }
        }

        if currentState.isScrollLengthExceeded() {
            // Give up at this point, no more data
            stopTicker()
            return
        }

        // Get the dot representation for this view and draw it
        let dotRepresentation = currentState.dotRepresentation()

        if let reportableLength = dotRepresentation.reportableDataLength {
            if reportableLength < fedDataLength {
                self.delegate?.tickerView?(self, tickerReachedPosition: reportableLength)
            }
        }

        self.drawDotRepresentation(dotRepresentation)
        self.currentTickerState = currentState

        self.updateTickerTimer?.invalidate()
        self.updateTickerTimer =
            Timer.scheduledTimer(timeInterval: tickDelaySeconds,
                                                   target: self,
                                                   selector: #selector(advanceAndUpdateTicker),
                                                   userInfo: nil,
                                                   repeats: false)
    }
}

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

import UIKit
import JATickerView

class ViewController: UIViewController, JATickerViewDelegate {
    @IBOutlet weak var tickerView: JATickerView?
    @IBOutlet weak var isOnSwitch: UISwitch?
    @IBOutlet weak var useColorsSwitch: UISwitch?
    @IBOutlet weak var slider: UISlider?
    @IBOutlet weak var position: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let ticker = self.tickerView else {
            return
        }

        ticker.delegate = self
        ticker.startTicker()
    }

    func tickerView(_ tickerView: JATickerView,
                    tickerDataAtEnd currentLength: UInt) -> String {
        NSLog("tickerDataAtEnd currentLength=" + String(currentLength))
        if currentLength == 0 {
            return "This is a test start to the ticker string. <>^#? >>>"
        } else {
            return "This will repeat forever. Lorem ipsum dolor sit amet,"
        }
    }

    /**
     Implement this delegate method to change the image used for an individual light bulb in the
     ticker when the light is on. A corresponding method imageForLightOff* can be
     used to specify the light bulb
     image when the light is off.

     - parameter tickerView: The ticker view
     - parameter xCoord: Light bulb x coordinate, starting from 0 on the left
     - parameter yCoord: Light bulb y coordinate, starting from 0 on the top
     - returns: UIImage of the bulb when it is on, or nil if the default should be used.
     */
    func tickerView(_ tickerView: JATickerView,
                    imageForLightOnAtX xCoord: UInt, andY yCoord: UInt) -> UIImage? {
        guard let colorSwitch = useColorsSwitch else {
            return nil
        }
        if !colorSwitch.isOn {
            return nil
        }
        switch (xCoord % 20) / 4 {
        case 0:
            return UIImage.jaTickerViewDotImage(.blue)
        case 1:
            return UIImage.jaTickerViewDotImage(.orange)
        case 2:
            return UIImage.jaTickerViewDotImage(.red)
        case 3:
            return UIImage.jaTickerViewDotImage(.yellow)
        default:
            return UIImage.jaTickerViewDotImage(.green)
        }
    }

    /**
     By default, only letters A-Z and numbers 1-9 get digitized by the ticker (the string is
     always converted to uppercase). To supply digitization definitions
     for other characters,
     this delegate method must be overridden.
     Return nil if it is unknown how to digitize a particular character
     (it will be displayed
     as an empty space instead).

     - parameter tickerView: The ticker view
     - parameter character: The character to retrieve a digitized representation of
     - returns: Digitized representation of the character, or nil if it should be blank
     */
    func tickerView(_ tickerView: JATickerView,
                    definitionForCharacter character: unichar) -> JATickerChar? {
        NSLog("definitionForCharacter called for " + String(character))
        if character == "<".utf16.first {
            return JATickerChar(ASCIIString:
                        "   .." +
                        " ..  " +
                        ".    " +
                        ".    " +
                        " ..  " +
                        "   ..")
        } else if character == ">".utf16.first {
            return JATickerChar(ASCIIString:
                        "..   " +
                        "  .. " +
                        "    ." +
                        "    ." +
                        "  .. " +
                        "..   ")
        } else {
            return nil
        }
    }


    func tickerView(_ tickerView: JATickerView,
                    tickerReachedPosition position: UInt) {
        self.position?.text = "Ticker position: " + String(position)
    }

    @IBAction func onIsTickerOnChanged(_ sender: UISwitch) {
        guard let onSwitch = self.isOnSwitch,
              let ticker = self.tickerView else {
            return
        }

        if onSwitch.isOn {
            ticker.startTicker()
        } else {
            ticker.stopTicker()
        }
    }

    @IBAction func onUseColorsChanged(_ sender: UISwitch) {
        guard let ticker = self.tickerView else {
            return
        }
        ticker.flushCacheOfImagesForLights()
    }

    fileprivate let kTickerMaxSpeedSecs: Float = 0.01
    fileprivate let kTickerMinSpeedSecs: Float = 0.8

    @IBAction func onSpeedSliderChanged(_ sender: UISlider) {
        guard let ticker = self.tickerView,
              let slider = self.slider else {
            return
        }

        // sliderVal = 0 -> fastest (least delay)
        // sliderVal = 1 -> slowest (most delay)
        ticker.tickDelaySeconds = Double(kTickerMinSpeedSecs +
                slider.value*(kTickerMaxSpeedSecs-kTickerMinSpeedSecs))
    }

    @IBAction func onRestartTickerButtonTapped(_ sender: UIButton) {
        guard let ticker = self.tickerView,
            let isOn = self.isOnSwitch else {
                return
        }
        ticker.clearAllDataFromTicker()
        ticker.startTicker()
        isOn.isOn = ticker.isStarted
    }
}

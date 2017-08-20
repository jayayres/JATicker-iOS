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

extension UIImage {
    /**
     Return the image with the specified name, first checking in the JATickerView bundle and then
     falling back to the main bundle if not found

     - parameter name: Name of the image to load
     - returns: Image, or nil if it could not be loaded
     */
    public class func jaTickerViewImageNamed(_ name: String) -> UIImage? {
        let bundleByClass = Bundle(for: JATickerView.self)
        if let image = UIImage(named: name,
                               in: bundleByClass,
                               compatibleWith: nil) {
            return image
        }

        if let bundleByName = Bundle(identifier: JATickerViewConstants.JATickerBundleName) {
            if let image = UIImage(named: name,
                                   in: bundleByName,
                                   compatibleWith: nil) {
                return image
            }
        }

        return UIImage(named: name)
    }

    /**
     Load a dot image of the specified color

     - parameter color: The dot color
     - returns: Dot image, or nil if none could be loaded
     */
    public class func jaTickerViewDotImage(_ color: JATickerDotColor) -> UIImage? {
        switch color {
        case JATickerDotColor.defaultOn, JATickerDotColor.green:
            return UIImage.jaTickerViewImageNamed("greendot")
        case JATickerDotColor.defaultOff, JATickerDotColor.black:
            return UIImage.jaTickerViewImageNamed("blackdot")
        case JATickerDotColor.yellow:
            return UIImage.jaTickerViewImageNamed("yellowdot")
        case JATickerDotColor.red:
            return UIImage.jaTickerViewImageNamed("reddot")
        case JATickerDotColor.blue:
            return UIImage.jaTickerViewImageNamed("bluedot")
        case JATickerDotColor.orange:
            return UIImage.jaTickerViewImageNamed("orangedot")
        }
    }

    /**
     Load the default dot image for the on or off state

     - parameter isOn: Whether to load the default for the on state
     - returns: Dot image, or nil if none could be loaded
     */
    public class func jaTickerViewDefaultDotColorForState(_ isOn: Bool) -> UIImage? {
        return isOn ? jaTickerViewDotImage(JATickerDotColor.defaultOn) :
                      jaTickerViewDotImage(JATickerDotColor.defaultOff)
    }
}

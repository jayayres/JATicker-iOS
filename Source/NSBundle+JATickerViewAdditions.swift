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

extension NSBundle {
    /**
     Return the file contents with the specified name, first checking in the JATickerView
     bundle and then
     falling back to the main bundle if not found

     - parameter name: File name of the image, without the extension
     - parameter type: File extension
     - returns: File contents or nil if it could not be loaded
     */
    class func jaTickerContentsOfFile(name: String, type: String) -> String? {
        let bundleByClass = NSBundle(forClass: JATickerView.self)
        if let fileRoot = bundleByClass.pathForResource(name, ofType: type) {
            do {
                return try String(contentsOfFile: fileRoot, encoding: NSUTF8StringEncoding)
            } catch {
                return nil
            }
        } else if let bundle = NSBundle(identifier: JATickerViewConstants.JATickerBundleName) {
            if let fileRoot = bundle.pathForResource(name, ofType: type) {
                do {
                    return try String(contentsOfFile: fileRoot, encoding: NSUTF8StringEncoding)
                } catch {
                    return nil
                }
            }
        } else if let fileRoot = NSBundle.mainBundle().pathForResource(name, ofType: type) {
            do {
                return try String(contentsOfFile: fileRoot, encoding: NSUTF8StringEncoding)
            } catch {
                return nil
            }
        }
        return nil
    }
}

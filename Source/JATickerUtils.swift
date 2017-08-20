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
 Utility methods for a specific instance of the ticker. This class is not a singleton
 but instead a separate instance should be created for each ticker.
 */
class JATickerUtils {
    /**
     Map of character to digitized representation of the character
     */
    fileprivate var charDict: [String: JATickerChar] = [:]

    /**
     Ticker characters which are known to have no digitized representation, to avoid
     repeatedly asking the client
     */
    fileprivate var undefinedChars: Set<String> = Set(minimumCapacity: 50)

    weak var tickerDelegate: JATickerViewDelegate?
    weak var tickerView: JATickerView?

    /**
    Initialize the utils, including reading in the symbols file
    */
    convenience init() {
        self.init(loadSymbols: true)
    }

    /**
     Initialize the utils

     - parameter loadSymbols: Whether this utils should also load the symbols file
     */
    init(loadSymbols: Bool) {
        if !loadSymbols {
            return
        }

        // Read the symbols file
        if let fileContents = Bundle.jaTickerContentsOfFile("symbols", type: "txt") {
            let allLinedStrings =
                fileContents.components(
                    separatedBy: CharacterSet.newlines)

            var nextChar = JATickerChar()
            var charLineOffset = 0
            var nextCharStr = "NOTHING"

            for line in allLinedStrings {
                if line.characters.count == 1 && line != " " && line != "." {
                    if nextCharStr != "NOTHING" {
                        // Save the current char
                        charDict[nextCharStr] = nextChar
                    }
                    nextCharStr = line
                    nextChar = JATickerChar()
                    charLineOffset = 0
                } else if charLineOffset <= 5 {
                    for j in 0..<line.characters.count {
                        if line[line.characters.index(line.startIndex, offsetBy: j)] == "." {
                            nextChar.setDot(xCoord: j, yCoord: charLineOffset)
                        }
                    }
                    charLineOffset += 1
                }
            }
        }
    }

    /**
    Normalize the ticker string to standardized whitespace characters.

    - parameter tickerStr: Non-normalized ticker string
    - returns: Normalized ticker string
    */
    func trimAndConvertTickerStr(_ tickerStr: String) -> String {
        return tickerStr.replacingOccurrences(
            of: " ",
            with: "_").replacingOccurrences(
                of: ".",
                with: "*")
    }

    /**
    Compute total number of ticker dots horizontally needed to represent the
    entire ticker string

    - parameter tickerStr: The ticker string
    - returns: Total number of required dots horizontally required
    */
    func totalDotWidthForTickerStr(_ tickerStr: String) -> Int {
        var nextChar: String? = nil
        var totalLength = 0
        for charIndex in 0..<tickerStr.characters.count {
            let startIndex = tickerStr.characters.index(tickerStr.startIndex, offsetBy: charIndex)
            let endIndex = tickerStr.characters.index(tickerStr.startIndex, offsetBy: charIndex+1)
            nextChar = tickerStr.substring(with: startIndex..<endIndex)
            if nextChar == "*" || nextChar == "|" {
                totalLength += 1
            } else {
                totalLength += JATickerChar.kDotCharWidth
            }
        }
        return totalLength
    }

    /**
    Different ticker characters take up a different number of ticker dots
    horizontally (e.g. single-dot-space after a letter or a period only take up 1
    dot, whereas most characters take up more. This method returns the number of dots
    needed for the character at the specified index in the ticker string.

    - parameter tickerStr: The ticker string
    - parameter charIndex: The index into the string
    - returns: Number of ticker dots needed to represent the character horizontally
    */
    func dotWidthXForCharacterAtIndex(_ tickerStr: String, charIndex: Int) -> Int {
        var nextChar: String? = nil
        if tickerStr.characters.count > charIndex {
            let startIndex = tickerStr.characters.index(tickerStr.startIndex, offsetBy: charIndex)
            let endIndex = tickerStr.characters.index(tickerStr.startIndex, offsetBy: charIndex+1)
            nextChar = tickerStr.substring(with: startIndex..<endIndex)
            if nextChar == "*" || nextChar == "|" {
                return 1
            } else {
                return JATickerChar.kDotCharWidth
            }
        }
        return JATickerChar.kDotCharWidth
    }

    /**
    Return whether the character at the specified index is one that was internally added,
    rather than specified by the delegate. For example, an extra dot is added after every letter
    via the metadata character |.

    - parameter tickerStr: The ticker string
    - parameter charIndex: The index into the string
    - returns: Whether the specified character is a metadata character
    */
    func isMetadataCharAtIndex(_ tickerStr: String, charIndex: Int) -> Bool {
        if tickerStr.characters.count > charIndex {
            let startIndex = tickerStr.characters.index(tickerStr.startIndex, offsetBy: charIndex)
            let endIndex = tickerStr.characters.index(tickerStr.startIndex, offsetBy: charIndex+1)
            let nextChar = tickerStr.substring(with: startIndex..<endIndex)
            return nextChar == "|"
        }
        return false
    }

    /**
    Look up the digitized representation of a character in the string

    - parameter tickerStr: The ticker string
    - parameter charIndex: The index into the string
    - returns: Digitized representation, or nil if it could not be loaded
    */
    func lookupDigitizedCharAtIndex(_ tickerStr: String, charIndex: Int) -> JATickerChar? {
        if tickerStr.characters.count > charIndex {
            let startIndex = tickerStr.characters.index(tickerStr.startIndex, offsetBy: charIndex)
            let endIndex = tickerStr.characters.index(tickerStr.startIndex, offsetBy: charIndex+1)
            let nextChar = tickerStr.substring(with: startIndex..<endIndex)
            return lookupDigitizedChar(nextChar)
        }
        return nil
    }

    /**
     Look up the digitized representation of a character in the string

     - parameter nextChar: The single-length string for the character
     - returns: Digitized representation, or nil if it could not be loaded
     */
    func lookupDigitizedChar(_ nextChar: String) -> JATickerChar? {
        if nextChar.characters.count != 1 {
            return charDict[" "]
        }
        var chr = charDict[nextChar]
        if chr != nil {
            return chr
        }

        if let tickerView = self.tickerView, let tickerDelegate = self.tickerDelegate {
            // See if the delegate can provide one, unless the delegate has
            // already been asked
            if !undefinedChars.contains(nextChar) && nextChar != "_" && nextChar != " " {
                chr = tickerDelegate.tickerView?(
                            tickerView,
                            definitionForCharacter: nextChar.utf16.first!)
            }
        }

        if chr != nil {
            charDict[nextChar] = chr
        } else {
            undefinedChars.insert(nextChar)
        }
        return charDict[" "]
    }

    /**
    Add metadata characters to the ticker string representing extra dots to add

    - parameter tickerStr: The ticker string without metadata
    - returns: The ticker string with metadata
    */
    func formatTickerStringWithMetadata(_ tickerStr: String) -> String {
        let input = tickerStr.uppercased()
        let length = input.characters.count
        var index = 0
        var res = ""
        for char in input.characters {
            res += String(char)
            if index < (length - 1) {
                res += "|"
            }
            index += 1
        }
        return res
    }

    /**
     Check if the image for a specified ticker dot has been changed from the default by
     the delegate.

     - parameter isOn: Whether the image being checked is for the on dot rather than the off dot
     - parameter xCoord: X coordinate starting from 0 on the left
     - parameter yCoord: Y coordinate starting from 0 on the top
     - returns: Overridden dot image, or nil if the default should be used
     */
    func checkDelegateForDotImage(isOn: Bool, xCoord: UInt, yCoord: UInt) -> UIImage? {
        guard let delegate = self.tickerDelegate,
            let tickerView = self.tickerView else {
            return nil
        }
        var image: UIImage? = nil
        if isOn {
            image = delegate.tickerView?(tickerView,
                                         imageForLightOnAtX: UInt(xCoord),
                                         andY: UInt(yCoord))
            if image == nil {
                image = UIImage.jaTickerViewDotImage(JATickerDotColor.defaultOn)
            }
        } else {
            image = delegate.tickerView?(tickerView,
                                         imageForLightOffAtX: UInt(xCoord),
                                         andY: UInt(yCoord))
            if image == nil {
                image = UIImage.jaTickerViewDotImage(JATickerDotColor.defaultOff)
            }
        }
        return image
    }
}

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

/**
 Digitized representation of a character suitable for indicating
 which ticker dots should be on and which should be off.
 */
@objc public class JATickerChar: NSObject {
    /**
    Number of dots typically taken up horizontally for each character
    */
    public static let kDotCharWidth: Int = 5

    /**
    Number of dots taken up vertically for each character
    */
    public static let kDotCharHeight: Int = 6

    /**
    Required length of the initialization string
    */
    private static let kDotInitializationLength = kDotCharWidth * kDotCharHeight

    /**
     2D array of booleans representing the dots
     */
    private var dots: [[Bool]] = [[Bool]](count: JATickerChar.kDotCharWidth, repeatedValue:
        [Bool](count: JATickerChar.kDotCharHeight, repeatedValue:false))

    // MARK: - Initialization

    /**
     Specify a string of length kDotCharWidth * kDotCharHeight, with only the characters
     . and the empty space, to indicate how to digitize the character on the ticker.

     - parameter ASCIIString: Dot representation of the string
     */
    public convenience init(ASCIIString string: String) {
        self.init()
        if string.characters.count != JATickerChar.kDotInitializationLength {
            NSLog("Error in JATickerChar init: dot definition must consist of exactly " +
                  String(JATickerChar.kDotCharWidth) + " x " + String(JATickerChar.kDotCharHeight) +
                  " characters, either . or the empty space.")
            return
        }

        for xCoord in (0..<dots.count) {
            for yCoord in (0..<dots[xCoord].count) {
                let nextIndex = string.startIndex.advancedBy(
                                    yCoord*JATickerChar.kDotCharWidth + xCoord)
                let dotCharacter = string[nextIndex]
                if dotCharacter == "." {
                    self.setDot(xCoord: xCoord, yCoord: yCoord)
                } else if dotCharacter != " " {
                    NSLog("Error in JATickerChar init: invalid character " + String(dotCharacter) +
                          ". Characters must be either either . or the empty space.")
                }
            }
        }
    }

    // MARK: - Public methods

    /**
     Manually set a dot to light up for the ticker

     - parameter xCoord: Dot X coordinate to turn on, 0 <= xCoord <= kDotCharWidth
     - parameter yCoord: Dot Y coordinate to turn on, 0 <= yCoord = kDotCharHeight
     */
    public func setDot(xCoord xCoord: Int, yCoord: Int) {
        if xCoord < 0 || xCoord >= self.dots.count {
            return
        }
        if yCoord < 0 || yCoord >= dots[0].count {
            return
        }
        self.dots[xCoord][yCoord] = true
    }

    /**
     Whether or not the dot at the given indices should be lit by the ticker

     - parameter xCoord: Dot X coordinate to check, 0 <= xCoord <= kDotCharWidth
     - parameter yCoord: Dot Y coordinate to check, 0 <= yCoord = kDotCharHeight
     - returns: True if the dot should be lit up
     */
    public func shouldLightDot(xCoord xCoord: Int, yCoord: Int) -> Bool {
        if xCoord < 0 || xCoord >= self.dots.count {
            return false
        }
        if yCoord < 0 || yCoord >= dots[0].count {
            return false
        }
        return dots[xCoord][yCoord]
    }
}

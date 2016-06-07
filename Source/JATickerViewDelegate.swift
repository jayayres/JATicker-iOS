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
 Callers implement this delegate to supply data to the ticker and receive
 feedback about how far it has ticked.
 */
@objc public protocol JATickerViewDelegate {
    /**
     Polls for more ticker data to be appended to the end of the ticker.
     Implementation of this method is mandatory.

     - parameter tickerView: Active ticker view
     - parameter tickerDataAtEnd: Current length in characters that the client has supplied so
                                  far to the ticker. May be used as an index by the client in
                                  looking up what ticker data to supply next.
     - returns: Characters to show on the ticker next on the right, in a forward scroll
     */
    optional func tickerView(tickerView: JATickerView,
                             tickerDataAtEnd currentLength: UInt) -> String

    /**
     The image to use to render an "on" lightbulb at the given cell (X, Y),
     relative to the top left of where the ticker is shown. If this method is
     not implemented, uses a default image.
     Images for all dots must be the exact same, square, dimensions, otherwise
     the image will not be used.

     - parameter tickerView: Active ticker view
     - parameter imageForLightOnAtX: X coordinate of the ticker starting from 0 on the left
     - parameter andY: Y coordinate of the ticker starting from 0 on the top
     - returns: Image, or nil if the default should be used
     */
    optional func tickerView(tickerView: JATickerView,
                             imageForLightOnAtX xCoord: UInt, andY yCoord: UInt) -> UIImage?

    /**
     The image to use to render an "off" lightbulb at the given cell (X, Y),
     relative to the top left of where the ticker is shown. If this method is
     not implemented, uses a default image.
     Images for all dots must be the exact same, square, dimensions, otherwise
     the image will not be used.

     - parameter tickerView: Active ticker view
     - parameter imageForLightOnAtX: X coordinate of the ticker starting from 0 on the left
     - parameter andY: Y coordinate of the ticker starting from 0 on the top
     - returns: Image, or nil if the default should be used
     */
    optional func tickerView(tickerView: JATickerView,
                             imageForLightOffAtX xCoord: UInt,
                             andY yCoord: UInt) -> UIImage?

    /**
     When the ticker encounters a character that it does not know how to digitize,
     it polls the delegate to see if the client can supply a digitized definition.
     A digitized definition indicates which lights to light up on the ticker to display
     the character. Should return nil if the delegate cannot provide a
     definition for this character.

     - parameter tickerView: Active ticker view
     - parameter character: Character to digitize
     - returns: Digitized character definition, or nil if the client does not have one
     */
    optional func tickerView(tickerView: JATickerView,
                             definitionForCharacter character: unichar) -> JATickerChar?

    /**
     Optional delegate method that calls back to the client once the ticker has
     ticked past a certain number of characters. Can be used to stop the ticker
     once it has reached a certain point.

     - parameter tickerView: Active ticker view
     - parameter tickerReachedPosition: Index of the leftmost character currently
                                        displayed on the ticker, from the characters supplied
                                        so far to the ticker by the client.
     */
    optional func tickerView(tickerView: JATickerView,
                             tickerReachedPosition position: UInt)
}

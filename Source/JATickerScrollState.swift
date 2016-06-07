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
 Defines the state for a specific point in time on the ticker as it is scrolling left.
 Includes the total number of ticker dots elapsed so far on the ticker and the entire
 ticker string including characters that have already been scrolled past. Permits
 creation of the next scroll state and of a dot representation for the current state.
 */
class JATickerScrollState {
    let tickerStr: String

    let dotScrollX: Int
    let totalDotWidth: Int

    weak var utils: JATickerUtils?

    /**
     Initializes the scroll state

     - parameter tickerStr: String representation of the text to render including whitespace markers
                            and including text that has already been scrolled past.
     - parameter dotScrollX: Number of ticker dots that have already scrolled past in this state
     - parameter utils: Utilities object
     */
    init(tickerStr: String, dotScrollX: Int, utils: JATickerUtils) {
        self.utils = utils
        self.dotScrollX = dotScrollX
        self.tickerStr = utils.trimAndConvertTickerStr(tickerStr)
        totalDotWidth = utils.totalDotWidthForTickerStr(self.tickerStr)
    }

    /**
     Compute the next state from the current one, assuming a single dot scroll to the right

     - returns: The next state, or nil if there is no valid next state
     */
    func nextState() -> JATickerScrollState? {
        guard let utils = self.utils else {
            return nil
        }

        return JATickerScrollState(tickerStr: self.tickerStr,
                                   dotScrollX: self.dotScrollX + 1,
                                   utils: utils)
    }

    /**
     True if no characters remain in the ticker to be rendered in the dot representation
     of the current state (it would render as all blanks)

     - returns: True if no characters remain
     */
    func isScrollLengthExceeded() -> Bool {
        return self.dotScrollX >= self.totalDotWidth
    }

    /**
     True if more data for the ticker must be requested in the current state
     to avoid the user seeing a gap in data onscreen in the next state

     - returns: True if more data must be immediately requested
     */
    func readyToAskForMoreData() -> Bool {
        return self.dotScrollX >=
            (self.totalDotWidth -
                JATickerView.kTickerThresholdToRequestMoreData * JATickerChar.kDotCharWidth)
    }

    /**
     Compute a dot representation of the current ticker state, specifically, for the dots
     in the ticker, which character to show for that dot, and which slice index in the digitized
     representation of that character to show.

     - returns: The dot representation
     */
    func dotRepresentation() -> JATickerDotRepresentation {
        return JATickerDotRepresentation(state: self)
    }
}

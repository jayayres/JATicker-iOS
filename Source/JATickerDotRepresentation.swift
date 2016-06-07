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
 Contains all information needed to draw the ticker in its current horizontal scroll state,
 including the character to draw in each dot column, and the dot index within the character's
 digitized representation to draw.
 */
class JATickerDotRepresentation {
    /**
    Worst-case assessment of how many dots horizontally could be visible at once, to avoid
    computing the dot representation further than that to the right
    */
    let maxDotsVisibleOnGridX = 300

    /**
    Array indexed by dot x coordinate starting from 0 on the left, to a
    tuple of a digitized character
    and the X index within that digitized character, to render in
    that ticker column onscreen.
    */
    let dotGrid: [(JATickerChar?, Int)]

    /**
    If the leftmost column in the dot representation draws the leftmost dot of some character,
    this value is set to the index in the original ticker string of that character. Otherwise,
    it is set to nil
    */
    var reportableDataLength: UInt?

    /**
    Initialize the dot representation based on its containing scroll state

    - parameter state: Current scroll state of the ticker used to generate the dot representation
    */
    init(state: JATickerScrollState) {
        guard let utils = state.utils else {
            dotGrid = []
            return
        }
        var grid = [(JATickerChar?, Int)]()

        var currentDotOffset = 0
        var numberNonMetadataCharacters: UInt = 0
        for i in 0..<state.tickerStr.characters.count {
            let thisDotOffset = utils.dotWidthXForCharacterAtIndex(state.tickerStr, charIndex: i)
            let thisChar = utils.lookupDigitizedCharAtIndex(state.tickerStr, charIndex: i)
            if !utils.isMetadataCharAtIndex(state.tickerStr, charIndex: i) {
                numberNonMetadataCharacters += 1
            }
            for j in 0..<thisDotOffset {
                if currentDotOffset >= state.dotScrollX {
                    if grid.count == 0
                        && j == 0
                        && !utils.isMetadataCharAtIndex(state.tickerStr, charIndex: i) {
                        // Report that the ticker has just now reached this character
                        reportableDataLength = numberNonMetadataCharacters
                    }
                    grid.append((thisChar, j))
                    if grid.count >= maxDotsVisibleOnGridX {
                        break
                    }
                }
                currentDotOffset += 1
            }
        }
        self.dotGrid = grid
    }
}

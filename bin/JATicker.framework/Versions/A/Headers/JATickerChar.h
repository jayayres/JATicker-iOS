/**
 * Copyright 2013 Jay Ayres
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

#import <Foundation/Foundation.h>

#define kDotCharWidth 5
#define kDotCharHeight 6

/**
 * A definition for how a specific character should be digitized for display
 * on the ticker.
 **/
@interface JATickerChar : NSObject

/**
 * Initialize the character with all dots off by default.
 **/
-(id)init;

/**
 * Specify a string of length kDotCharWidth * kDotCharHeight, with only the characters
 * . and the empty space, to indicate how to digitize the character on the ticker.
 **/
-(id)initWithASCIIString:(NSString*)string;

/**
 * Manually set a dot to light up for the ticker, where 0 <= x < kDotCharWidth
 * and 0 <= y < kDotCharHeight .
 **/
-(void)setDot:(NSUInteger)x andY:(NSUInteger)y;

/**
 * Whether or not the dot at the given indices should be lit by the ticker
 **/
-(BOOL)shouldLightDot:(NSUInteger)x andY:(NSUInteger)y;

@end

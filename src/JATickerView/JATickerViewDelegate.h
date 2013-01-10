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

@class JATickerView;
@class JATickerChar;

@protocol JATickerViewDelegate <NSObject>

@optional

/**
 * Polls for more ticker data to be appended to the end of the ticker.
 **/
-(NSString*)tickerView:(JATickerView*)tickerView tickerDataAtEnd:(NSUInteger)currentLength;

/**
 * The image to use to render an "on" lightbulb at the given cell (X, Y), relative to the top left
 * of where the ticker is shown. If this method is not implemented, uses a default image.
 * Images for all dots must be the exact same, square, dimensions, otherwise the image will not be used.
 **/
-(UIImage*)tickerView:(JATickerView *)tickerView imageForLightOnAtX:(NSUInteger)x andY:(NSUInteger)y;

/**
 * The image to use to render an "off" lightbulb at the given cell (X,Y), relative to the top left
 * of where the ticker is shown. If this method is not implemented, uses a default image.
 * Images for all dots must be the exact same, square, dimensions, otherwise the image will not be used.
 **/
-(UIImage*)tickerView:(JATickerView *)tickerView imageForLightOffAtX:(NSUInteger)x andY:(NSUInteger)y;

/**
 * When the ticker encounters a character that it does not know how to digitize,
 * it polls the delegate to see if the client can supply a digitized definition.
 * A digitized definition indicates which lights to light up on the ticker to display
 * the character. Should return nil if the delegate cannot provide a definition for this character.
 **/
-(JATickerChar*)tickerView:(JATickerView *)tickerView definitionForCharacter:(unichar)c;

/**
 * Optional delegate method that calls back to the client once the ticker has
 * ticked past a certain number of characters. Can be used to stop the ticker
 * once it has reached a certain point.
 **/
-(void)tickerView:(JATickerView *)tickerView tickerReachedPosition:(NSUInteger)pos;

@end

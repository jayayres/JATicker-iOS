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

#import "ViewController.h"

@interface ViewController () <JATickerViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tickerView.delegate = self;
    [self.tickerView startTicker];
}

- (NSString*)tickerView:(JATickerView*)tickerView tickerDataAtEnd:(NSUInteger)currentLength {
    NSLog(@"tickerDataAtEnd currentLength=%lu", (unsigned long)currentLength);
    if (currentLength == 0) {
        return @"This is a test start to the ticker string. <>^#? >>>";
    }
    else {
        return @"This will repeat forever. Lorem ipsum dolor sit amet,";// consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ";
    }
}

/**
 * By default, only letters A-Z and numbers 1-9 get digitized by the ticker (the string is always
 * converted to uppercase). To supply digitization definitions for other characters,
 * this delegate method must be overridden.
 * Return nil if it is unknown how to digitize a particular character (it will be displayed
 * as an empty space instead).
 **/
- (JATickerChar*)tickerView:(JATickerView *)tickerView definitionForCharacter:(unichar)c {
    NSLog(@"definitionForCharacter called for %c", c);
    if ( c == '<' ) {
        return [[JATickerChar alloc] initWithASCIIString:
                [NSString stringWithFormat:@"%@%@%@%@%@%@",
                 @"   ..",
                 @" ..  ",
                 @".    ",
                 @".    ",
                 @" ..  ",
                 @"   .."]];
    }
    else if ( c == '>' ) {
        return [[JATickerChar alloc] initWithASCIIString:
                [NSString stringWithFormat:@"%@%@%@%@%@%@",
                 @"..   ",
                 @"  .. ",
                 @"    .",
                 @"    .",
                 @"  .. ",
                 @"..   "]];
    }
    else {
        return nil;
    }
}

- (void)tickerView:(JATickerView *)tickerView tickerReachedPosition:(NSUInteger)pos {
    [self.position setText:[NSString stringWithFormat:@"Ticker position: %lu", (unsigned long)pos]];
}

/**
 * Implement this delegate method to change the image used for an individual light bulb in the ticker
 * when the light is on. A corresponding method imageForLightOff* can be used to specify the light bulb
 * image when the light is off.
 **/
- (UIImage*)tickerView:(JATickerView *)tickerView imageForLightOnAtX:(NSUInteger)x andY:(NSUInteger)y {
    if (![self.useColorsSwitch isOn])
    {
        // Uses default
        return nil;
    }
    
    switch ((x % 20) / 4) {
        case 0:
            return [UIImage jaTickerViewDotImage:JATickerDotColorBlue];
        case 1:
            return [UIImage jaTickerViewDotImage:JATickerDotColorOrange];
        case 2:
            return [UIImage jaTickerViewDotImage:JATickerDotColorRed];
        case 3:
            return [UIImage jaTickerViewDotImage:JATickerDotColorYellow];
    }
    return [UIImage jaTickerViewDotImage:JATickerDotColorGreen];
}

- (IBAction)onIsTickerOnChanged:(UISwitch *)sender {
    if ([self.isOnSwitch isOn]) {
        [self.tickerView startTicker];
    }
    else {
        [self.tickerView stopTicker];
    }
}

- (IBAction)onUseColorsChanged:(UISwitch *)sender {
    [self.tickerView flushCacheOfImagesForLights];
}

#define kTickerMaxSpeedSecs 0.01f
#define kTickerMinSpeedSecs 0.8f
#define kTickerSpeedRange (kTickerMaxSpeedSecs - kTickerMinSpeedSecs)

- (IBAction)onSpeedSliderChanged:(UISlider *)sender {
    CGFloat sliderVal = self.slider.value;
    // sliderVal = 0 -> fastest (least delay)
    // sliderVal = 1 -> slowest (most delay)
    self.tickerView.tickDelaySeconds = (sliderVal*kTickerSpeedRange) + kTickerMinSpeedSecs;
}

- (IBAction)onRestartTickerButtonTapped:(UIButton *)sender {
    [self.tickerView clearAllDataFromTicker];
    [self.tickerView startTicker];
    self.isOnSwitch.on = self.tickerView.isStarted;
}

@end

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

#import <UIKit/UIKit.h>
#import <JATicker/JATicker.h>

@interface ViewController : UIViewController<JATickerViewDelegate>
{
    JATickerView* tickerView;
    UISwitch* isOnSwitch;
    UISwitch* useColorsSwitch;
    UISlider* slider;
    UILabel* position;
}

@property (nonatomic, strong) IBOutlet JATickerView* tickerView;
@property (nonatomic, strong) IBOutlet UISwitch* isOnSwitch;
@property (nonatomic, strong) IBOutlet UISwitch* useColorsSwitch;
@property (nonatomic, strong) IBOutlet UISlider* slider;
@property (nonatomic, strong) IBOutlet UILabel* position;

-(IBAction)onIsTickerOnChanged:(id)sender;
-(IBAction)onUseColorsChanged:(id)sender;
-(IBAction)onSpeedSliderChanged:(id)sender;

@end

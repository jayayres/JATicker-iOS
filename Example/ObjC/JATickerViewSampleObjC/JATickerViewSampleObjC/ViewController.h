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

#import <UIKit/UIKit.h>
#import <JATickerView/JATickerView-Swift.h>

@interface ViewController : UIViewController

@property (nonatomic, weak) IBOutlet JATickerView* tickerView;
@property (nonatomic, weak) IBOutlet UISwitch* isOnSwitch;
@property (nonatomic, weak) IBOutlet UISwitch* useColorsSwitch;
@property (nonatomic, weak) IBOutlet UISlider* slider;
@property (nonatomic, weak) IBOutlet UILabel* position;

@end


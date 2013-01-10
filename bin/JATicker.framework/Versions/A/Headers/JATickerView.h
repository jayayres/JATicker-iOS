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

#import "JATickerViewDelegate.h"

#define kDefaultStockTickDelaySeconds 0.16f

#define kTickerGreenDot [UIImage imageNamed:@"JATickerResources.bundle/greendot.tiff"]
#define kTickerBlackDot [UIImage imageNamed:@"JATickerResources.bundle/blackdot.tiff"]
#define kTickerYellowDot [UIImage imageNamed:@"JATickerResources.bundle/yellowdot.tiff"]
#define kTickerRedDot [UIImage imageNamed:@"JATickerResources.bundle/reddot.tiff"]
#define kTickerBlueDot [UIImage imageNamed: @"JATickerResources.bundle/bluedot.tiff"]
#define kTickerOrangeDot [UIImage imageNamed:@"JATickerResources.bundle/orangedot.tiff"]

@interface JATickerView : UIView
{
    __unsafe_unretained id<JATickerViewDelegate> delegate;
    CGFloat tickDelaySeconds;
    BOOL isStarted;
}

/**
 * The delegate to feed more content to the ticker
 **/
@property (nonatomic, assign) id<JATickerViewDelegate> delegate;

/**
 * How much time in seconds to sleep between ticker ticks
 **/
@property (nonatomic, assign) CGFloat tickDelaySeconds;

/**
 * Whether or not the ticker is ticking
 **/
@property (nonatomic, assign) BOOL isStarted;

/**
 * Tell the ticker to start moving
 **/
- (void)startTicker;

/**
 * Tell the ticker to stop moving
 **/
- (void)stopTicker;

/**
 * Instruct the ticker view to ask the delegate again for the images that should
 * be used for each light of the ticker. Not necessary to call this unless the
 * image for a ticker dot ever changes at runtime. 
 **/
- (void)flushCacheOfImagesForLights;

@end
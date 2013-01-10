//
//  JATickerViewDelegate.h
//  JATickerView
//
//  Created by Jay on 1/1/13.
//  Copyright (c) 2013 jaysapps. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JATickerView;

@protocol JATickerViewDelegate <NSObject>

@optional

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

@end

//
//  JATickerView.h
//  JATickerView
//
//  Created by Jay on 1/1/13.
//  Copyright (c) 2013 jaysapps. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JATickerViewDelegate.h"

#define NUM_DOTS_Y 8

@interface JATickerView : UIView
{
@private
    NSMutableDictionary* charDict;
    NSString* tickerStr;
    NSMutableArray* imgViews;
    CGFloat numDotsX;
    CGFloat dotWid;
    CGFloat dotHgt;
    NSValue* dotPixelDimensions;
    UIButton* tapButton;
    BOOL isResizing;
    __unsafe_unretained id<JATickerViewDelegate> delegate;
}

@property (nonatomic, strong) NSMutableDictionary* charDict;
@property (nonatomic, copy) NSString* tickerStr;
@property (nonatomic, strong) NSMutableArray* imgViews;
@property (nonatomic, assign) CGFloat numDotsX;
@property (nonatomic, assign) CGFloat dotWid;
@property (nonatomic, assign) CGFloat dotHgt;
@property (nonatomic, strong) NSValue* dotPixelDimensions;
@property (nonatomic, strong) IBOutlet UIButton* tapButton;
@property (nonatomic, assign) BOOL isResizing;
@property (nonatomic, assign) id<JATickerViewDelegate> delegate;

- (void)initMethod:(CGRect)frame;
- (void)reinitLightsAfterResize:(CGRect)frame;
- (NSString*)updateTickerStr:(NSString*)str andInnerDotOffset:(NSUInteger)dotOffset;

@end
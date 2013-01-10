//
//  JATickerChar.h
//  JATickerView
//
//  Created by Jay on 1/1/13.
//  Copyright (c) 2013 jaysapps. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CHAR_WIDTH 5
#define CHAR_HEIGHT 6

@interface JATickerChar : NSObject
{
    NSMutableArray* dots;
}

@property (nonatomic, strong) NSMutableArray *dots;

-(BOOL)shouldLightDot:(NSUInteger)x andY:(NSUInteger)y;
-(void)setDot:(NSUInteger)x andY:(NSUInteger)y;

@end

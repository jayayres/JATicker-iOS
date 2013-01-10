//
//  JATickerChar.m
//  JATickerView
//
//  Created by Jay on 1/1/13.
//  Copyright (c) 2013 jaysapps. All rights reserved.
//

#import "JATickerChar.h"

@implementation JATickerChar

@synthesize dots;

- (id)init
{
    self = [super init];
    if (self) {
        self.dots = [NSMutableArray arrayWithCapacity:CHAR_WIDTH];
        for (NSUInteger i = 0; i < CHAR_WIDTH; i++)
        {
            NSMutableArray* height = [NSMutableArray arrayWithCapacity:CHAR_HEIGHT];
            for (NSUInteger j = 0; j < CHAR_HEIGHT; j++)
            {
                [height addObject:[NSNumber numberWithBool:NO]];
            }
            [dots addObject:height];
        }
    }
    
    return self;
}

-(BOOL)shouldLightDot:(NSUInteger)x andY:(NSUInteger)y
{
    //DebugLog(@"shouldLightDot %d %d", x, y);
    NSMutableArray* height = (NSMutableArray*)[dots objectAtIndex:x];
    NSNumber* num = (NSNumber*)[height objectAtIndex:y];
    return [num boolValue];
}

-(void)setDot:(NSUInteger)x andY:(NSUInteger)y
{
    NSMutableArray* height = (NSMutableArray*)[dots objectAtIndex:x];
    [height replaceObjectAtIndex:y withObject:[NSNumber numberWithBool:YES]];
}

@end

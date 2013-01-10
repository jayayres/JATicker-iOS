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
#import "JATickerChar.h"

@interface JATickerChar()
{
    NSMutableArray* dots;
}

@property (nonatomic, strong) NSMutableArray *dots;

@end

@implementation JATickerChar

@synthesize dots;

- (id)init
{
    self = [super init];
    if (self) {
        self.dots = [NSMutableArray arrayWithCapacity:kDotCharWidth];
        for (NSUInteger i = 0; i < kDotCharWidth; i++)
        {
            NSMutableArray* height = [NSMutableArray arrayWithCapacity:kDotCharHeight];
            for (NSUInteger j = 0; j < kDotCharHeight; j++)
            {
                [height addObject:[NSNumber numberWithBool:NO]];
            }
            [dots addObject:height];
        }
    }
    
    return self;
}

- (id)initWithASCIIString:(NSString*)string
{
    self = [self init];
    if (string == nil || ([string length] != (kDotCharWidth*kDotCharHeight)))
    {
        NSLog(@"Error in JATickerChar initWithASCIIString: dot definition must consist of exactly %d x %d characters, either . or the empty space.", kDotCharWidth, kDotCharHeight);
        return self;
    }
    for (NSUInteger x = 0; x < kDotCharWidth; x++)
    {
        for (NSUInteger y = 0; y < kDotCharHeight; y++)
        {
            NSUInteger nextInd = y*kDotCharWidth + x;
            unichar c = [string characterAtIndex:nextInd];
            if (c == '.')
            {
                [self setDot:x andY:y];
            }
            else if (c != ' ')
            {
                NSLog(@"Error in JATickerChar initWithASCIIString: invalid character at index %d. Characters must be either either . or the empty space.", nextInd);
            }
        }
    }
    return self;
}

-(BOOL)shouldLightDot:(NSUInteger)x andY:(NSUInteger)y
{
    NSMutableArray* height = (NSMutableArray*)[dots objectAtIndex:x];
    NSNumber* num = (NSNumber*)[height objectAtIndex:y];
    return [num boolValue];
}

-(void)setDot:(NSUInteger)x andY:(NSUInteger)y
{
    if (x >= kDotCharWidth || y >= kDotCharHeight)
    {
        return;
    }

    NSMutableArray* height = (NSMutableArray*)[dots objectAtIndex:x];
    [height replaceObjectAtIndex:y withObject:[NSNumber numberWithBool:YES]];
}

@end

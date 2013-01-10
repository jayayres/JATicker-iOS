//
//  JATickerView.m
//  JATickerView
//
//  Created by Jay on 1/1/13.
//  Copyright (c) 2013 jaysapps. All rights reserved.
//

#import "JATickerView.h"
#import "JATickerChar.h"
#import "JATickerViewDelegate.h"

#define DEFAULT_ON_IMAGE @"greendot.png"
#define DEFAULT_OFF_IMAGE @"blackdot.png"

@implementation JATickerView

@synthesize charDict, tickerStr, imgViews, numDotsX, dotWid, dotHgt, dotPixelDimensions, tapButton, isResizing, delegate;

- (void)initMethod:(CGRect)frame
{
    self.dotPixelDimensions = nil;
    self.delegate = nil;
    isResizing = FALSE;
    NSLog(@"Init method: frame=%f %f %f %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    // Initialization code
    
    // Read the symbols file
    NSString* filePath = @"symbols";
    NSString* fileRoot = [[NSBundle mainBundle]
                          pathForResource:filePath ofType:@"txt"];
    
    // read everything from text
    NSString* fileContents =
    [NSString stringWithContentsOfFile:fileRoot
                              encoding:NSUTF8StringEncoding error:nil];
    
    // first, separate by new line
    NSArray* allLinedStrings =
    [fileContents componentsSeparatedByCharactersInSet:
     [NSCharacterSet newlineCharacterSet]];
    
    self.charDict = [NSMutableDictionary dictionaryWithCapacity:50];
    
    JATickerChar* nextChar = [[JATickerChar alloc] init];
    NSUInteger charLineOffset = 0;
    NSString* nextCharStr = @"NOTHING";
    
    NSLog(@"file has %d lines", [allLinedStrings count]);
    
    for (NSUInteger i = 0; i < [allLinedStrings count]; i++)
    {
        NSString* line = (NSString*)[allLinedStrings objectAtIndex:i];
        if ([line length] == 1 && ![line isEqualToString:@" "] && ![line isEqualToString:@"."])
        {
            if (![nextCharStr isEqualToString:@"NOTHING"])
            {
                // Save the current char
                NSLog(@"Saving = |%@|", nextCharStr);
                
                [charDict setObject:nextChar forKey:nextCharStr];
            }
            nextCharStr = line;
            nextChar = [[JATickerChar alloc] init];
            charLineOffset = 0;
        }
        else if (charLineOffset <= 5)
        {
            for (NSUInteger j = 0; j < [line length]; j++)
            {
                if ([line characterAtIndex:j] == '.')
                {
                    //NSLog(@"setDot %d %d for char %@", j, charLineOffset, nextCharStr);
                    [nextChar setDot:j andY:charLineOffset];
                }
            }
            charLineOffset++;
        }
    }

    [self reinitLightsAfterResize:frame];
}

- (UIImage*)loadImageForDot:(BOOL)isOn atX:(NSUInteger)x andY:(NSUInteger)y
{
    UIImage* image = nil;
    if (self.delegate != nil)
    {
        if (isOn)
        {
            image = [self.delegate tickerView:self imageForLightOnAtX:x andY:y];
        }
        else
        {
            image = [self.delegate tickerView:self imageForLightOffAtX:x andY:y];
        }
    
        if (image != nil)
        {
            if (image.size.width != image.size.height)
            {
                NSLog(@"JATickerView illegal state: image at x=%d y=%d must be square but had size (%f,%f).", x, y, image.size.width, image.size.height);
                image = nil;
            }
        }
    }
    
    if (image == nil)
    {
        image = [UIImage imageNamed:(isOn ? DEFAULT_ON_IMAGE : DEFAULT_OFF_IMAGE)];
    }
    
    if (self.dotPixelDimensions == nil)
    {
        dotPixelDimensions = [NSValue valueWithCGSize:image.size];
    }
    else
    {
        CGSize size = [self.dotPixelDimensions CGSizeValue];
        if (size.width != image.size.width || size.height != image.size.height)
        {
            NSLog(@"JATickerView illegal state: image at x=%d y=%d must be the same pixel dimensions as the image at (0,0). Expected dimensions of (%f,%f) but got dimensions of (%f,%f).", x, y, size.width, size.height, image.size.width, image.size.height);
            
            // Ensure the default image is used when this happens
            image = [UIImage imageNamed:(isOn ? DEFAULT_ON_IMAGE : DEFAULT_OFF_IMAGE)];
        }
    }
    
    return image;
}

-(void)reinitLightsAfterResize:(CGRect)frame
{
    isResizing = TRUE;
    dotHgt = frame.size.height / NUM_DOTS_Y;
    dotWid = dotHgt;
    
    NSLog(@"TickerView frameWidth=%f dotWidth=%f", frame.size.width, dotWid);
    numDotsX = frame.size.width / dotWid;
    
    NSUInteger numDotsXInt = (NSUInteger)numDotsX + 1;
    NSLog(@"numDotsXInt = %d numDotsX=%f", numDotsXInt, numDotsX);
    // Set up the image views
    self.imgViews = [NSMutableArray arrayWithCapacity:numDotsXInt];
    
    CGFloat leftOffset = 0;
    for (NSUInteger i = 0; i < numDotsXInt; i++)
    {
        NSMutableArray* colViews = [NSMutableArray arrayWithCapacity:NUM_DOTS_Y];
        CGFloat topOffset = 0;
        for (NSUInteger j = 0; j < NUM_DOTS_Y; j++)
        {
            UIImage* image = [self loadImageForDot:NO atX:i andY:j];
            UIImageView* v = [[UIImageView alloc] initWithImage:image];
            [v setFrame:CGRectMake(leftOffset, topOffset, dotWid, dotHgt)];
            [self addSubview:v];
            [colViews addObject:v];
            topOffset += dotHgt;
        }
        
        leftOffset += dotWid;
        [imgViews addObject:colViews];
    }
    isResizing = FALSE;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    NSLog(@"initWithCoder");
    self = [super initWithCoder:decoder];
    if (self)
    {
        [self initMethod:self.frame];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"Init with frame=%f %f %f %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    self = [super initWithFrame:frame];
    if (self) {
        [self initMethod:frame];
        NSLog(@"Done init");
    }
    return self;
}

/**
 * str: The remaining characters to show
 * dotOffset: Value 0-4 as to how far into the first character the dots should appear
 **/
- (NSString*)updateTickerStr:(NSString*)str andInnerDotOffset:(NSUInteger)dotOffset
{
    NSString* decrChar = nil;
    NSUInteger remainingDotOffset = dotOffset;
    //NSLog(@"updateTickerStr: %d", dotOffset);
    NSString* testStr = [[str stringByReplacingOccurrencesOfString:@" " withString:@"_"]
                         stringByReplacingOccurrencesOfString:@"." withString:@"*"];
    NSUInteger charIndex = 0;
    NSString* nextChar = @" ";
    NSUInteger charLen = CHAR_WIDTH;
    if ([testStr length] > charIndex)
    {
        nextChar = [testStr substringWithRange:NSMakeRange(charIndex, 1)];
        if ([nextChar isEqualToString:@"*"] || [nextChar isEqualToString:@"|"])
        {
            charLen = 1;
        }
        charIndex++;
    }
    //NSLog(@"nextChar = |%@|", nextChar);
    //NSLog(@"char count= %d",[charDict count]);
    JATickerChar* chr = [charDict objectForKey:nextChar];
    //NSLog(@"here after chr");
    NSUInteger xOffInChar = remainingDotOffset;
    
    if (charLen <= remainingDotOffset)
    {
        remainingDotOffset -= charLen;
    }
    else
    {
        remainingDotOffset = 0;
    }
    
    //NSLog(@"Remaining dot offset after first 1=%d",remainingDotOffset);
    
    NSUInteger numDotsXInt = (NSUInteger)numDotsX + 1;
    BOOL hasDrawnCurChar = false;
    BOOL isNewChar = false;
    NSUInteger priorToFirstDrawLen = charLen;
    BOOL hasDrawn = false;
    NSUInteger realI = 0;
    NSUInteger numSkippedChars = 0;
    for (NSUInteger i = 0; i < numDotsXInt; i++)
    {
        if (isResizing)
        {
            // Stop immediately if the ticker view is resizing
            break;
        }
        if (xOffInChar < charLen)
        {
            if (i > 0 && isNewChar && !hasDrawnCurChar)
            {
                // The previous character(s) were not drawn at all due to dot offsets,
                // decrement i so that the next one is drawn in the proper spot
                if (i > priorToFirstDrawLen)
                {
                    i -= priorToFirstDrawLen;
                }
                else
                {
                    i = 0;
                }
                if (![nextChar isEqualToString:@"|"] && ![nextChar isEqualToString:@"*"] && dotOffset == 4)
                {
                    if (numSkippedChars > 1)
                    {
                        decrChar = nextChar;
                        //NSLog(@"DECREMENTED before %@ numSkipped=%d", nextChar, numSkippedChars);
                    }
                }
            }
            if (isNewChar)
            {
                hasDrawnCurChar = false;
            }
            
            if (!hasDrawn)
            {
                hasDrawn = true;
                //NSLog(@"i of first drawn=%d", realI);
            }
            NSMutableArray* colViews = (NSMutableArray*)[imgViews objectAtIndex:i];
            for (NSUInteger j = 1; j < (NUM_DOTS_Y-1); j++)
            {
                UIImageView* v = (UIImageView*)[colViews objectAtIndex:j];
                
                if ([chr shouldLightDot:xOffInChar andY:(j-1)])
                {
                    UIImage* image = [self loadImageForDot:YES atX:xOffInChar andY:(j-1)];
                    [v setImage:image];
                    //NSLog(@"Lit %d %d", i, j);
                }
                else
                {
                    UIImage* image = [self loadImageForDot:NO atX:xOffInChar andY:(j-1)];
                    [v setImage:image];
                    //NSLog(@"unlit %d %d", i, j);
                }
            }
            hasDrawnCurChar = true;
        }
        
        xOffInChar++;
        if (xOffInChar >= charLen)
        {
            // Pick the next character
            if (!hasDrawn)
            {
                priorToFirstDrawLen += charLen;
                numSkippedChars++;
            }
            nextChar = @" ";
            charLen = CHAR_WIDTH;
            if ([str length] > charIndex)
            {
                nextChar = [testStr substringWithRange:NSMakeRange(charIndex, 1)];
                //NSLog(@"nextChar = %@", nextChar);
                if ([nextChar isEqualToString:@"*"] || [nextChar isEqualToString:@"|"])
                {
                    charLen = 1;
                }
                charIndex++;
            }
            chr = [charDict objectForKey:nextChar];
            //NSLog(@"New char xOffInChar=%d", remainingDotOffset);
            xOffInChar = remainingDotOffset;
            
            if (charLen <= remainingDotOffset)
            {
                remainingDotOffset -= charLen;
            }
            else
            {
                remainingDotOffset = 0;
            }
            isNewChar = true;
        }
        else
        {
            isNewChar = false;
        }
        
        realI++;
    }
    
    return decrChar;
}

@end


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

#import "JATickerView.h"
#import "JATickerChar.h"
#import "JATickerViewDelegate.h"

#pragma mark - Constants

#define kTickerDefaultOnDot kTickerGreenDot
#define kTickerDefaultOffDot kTickerBlackDot

#define kJATickerNumDotsY 8

#define kTickerImageCacheCapacity 400

#define kTickerThresholdToRequestMoreData 60

@interface JATickerView()
{
    /**
     * Map of character to digitized representation of the character
     **/
    NSMutableDictionary* charDict;
    
    /**
     * Pending characters for the ticker
     **/
    NSString* curTickerStr;
    
    /**
     * UIImageViews for each dot
     **/
    NSMutableArray* imgViews;
    
    /**
     * Within the current character on the left-most portion of the ticker, how many dots have advanced
     **/
    NSUInteger curDotOffset;
    
    /**
     * Last character to be ticked
     **/
    NSString* lastDecrChar;
    
    /**
     * How many dots are present in the view in the x direction
     **/
    CGFloat numDotsX;
    
    /**
     * Dimensions of a dot UIImageView
     **/
    CGSize dotSize;
    
    /**
     * Last size of the ticker view
     **/
    NSValue* lastViewSize;
    
    /**
     * Dimensions of the source UIImages representing each dot
     **/
    NSValue* dotPixelDimensions;

    /**
     * Whether or not the ticker view is currently changing its dimensions
     **/
    BOOL isResizing;
    
    /**
     * How much ticker data has been fed already from the client
     **/
    NSUInteger fedDataLength;
    
    /**
     * How much ticker data has been reported back to the client
     * as having ticked by already
     **/
    NSUInteger reportedDataLength;
    
    /**
     * Cache of images for specific positions in the ticker
     **/
    NSMutableDictionary* imageCache;
    
    /**
     * Characters from the ticker that have been determined to not be
     * defined by the client already.
     **/
    NSMutableSet* undefinedChars;
}

@property (nonatomic, strong) NSMutableDictionary* charDict;
@property (nonatomic, copy) NSString* curTickerStr;
@property (nonatomic, strong) NSMutableArray* imgViews;
@property (nonatomic, assign) NSUInteger curDotOffset;
@property (nonatomic, copy) NSString* lastDecrChar;
@property (nonatomic, assign) CGFloat numDotsX;
@property (nonatomic, assign) CGSize dotSize;
@property (nonatomic, strong) NSValue* dotPixelDimensions;
@property (nonatomic, strong) NSValue* lastViewSize;
@property (nonatomic, assign) BOOL isResizing;
@property (nonatomic, assign) NSUInteger fedDataLength;
@property (nonatomic, assign) NSUInteger reportedDataLength;
@property (nonatomic, retain) NSMutableDictionary* imageCache;
@property (nonatomic, retain) NSMutableSet* undefinedChars;

- (void)initMethod:(CGRect)frame;
- (void)reinitLightsAfterResize:(CGRect)frame;
- (NSString*)updateTickerStr:(NSString*)str andInnerDotOffset:(NSUInteger)dotOffset;
- (JATickerChar*)lookupDigitizedCharacter:(NSString*)nextChar;

@end


@implementation JATickerView

@synthesize charDict, curTickerStr, imgViews, curDotOffset, lastDecrChar, numDotsX, dotSize, dotPixelDimensions, lastViewSize, isResizing, fedDataLength, reportedDataLength, imageCache, undefinedChars, delegate, tickDelaySeconds, isStarted;

#pragma mark - Private methods

/**
 * Common init method called by all the init constructors
 **/
- (void)initMethod:(CGRect)frame
{
    self.curTickerStr = @"";
    self.dotPixelDimensions = nil;
    self.delegate = nil;
    self.tickDelaySeconds = kDefaultStockTickDelaySeconds;
    self.fedDataLength = 0;
    self.reportedDataLength = 0;
    self.undefinedChars = [[NSMutableSet alloc] initWithCapacity:50];
    [self flushCacheOfImagesForLights];
    
    isResizing = FALSE;
    isStarted = FALSE;

    // Initialization code
    
    // Read the symbols file
    NSString* filePath = @"symbols";
    NSBundle *staticBundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"JATickerResources" withExtension:@"bundle"]];

    NSString* fileRoot = [staticBundle
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
    
    for (NSUInteger i = 0; i < [allLinedStrings count]; i++)
    {
        NSString* line = (NSString*)[allLinedStrings objectAtIndex:i];
        if ([line length] == 1 && ![line isEqualToString:@" "] && ![line isEqualToString:@"."])
        {
            if (![nextCharStr isEqualToString:@"NOTHING"])
            {
                // Save the current char
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
    NSString* cacheKey = [NSString stringWithFormat:@"%d_%d_%i", x, y, isOn];
    id cacheObj = [imageCache objectForKey:cacheKey];
    if (cacheObj != nil)
    {
        return (UIImage*)cacheObj;
    }
    
    UIImage* image = nil;
    if (self.delegate != nil)
    {
        if (isOn && [delegate respondsToSelector:@selector(tickerView:imageForLightOnAtX:andY:)])
        {
            image = [self.delegate tickerView:self imageForLightOnAtX:x andY:y];
            if (image == nil)
            {
                image = kTickerDefaultOnDot;
            }
        }
        else if ([delegate respondsToSelector:@selector(tickerView:imageForLightOffAtX:andY:)])
        {
            image = [self.delegate tickerView:self imageForLightOffAtX:x andY:y];
            if (image == nil)
            {
                image = kTickerDefaultOffDot;
            }
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
        image = isOn ? kTickerDefaultOnDot : kTickerDefaultOffDot;
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
            image = isOn ? kTickerDefaultOnDot : kTickerDefaultOffDot;
        }
    }
    
    [imageCache setObject:image forKey:cacheKey];
    return image;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    if (self.lastViewSize == nil)
    {
        [self reinitLightsAfterResize:self.frame];
    }
    else
    {
        CGSize curSize = self.frame.size;
        CGSize lastSize = [self.lastViewSize CGSizeValue];
        if (curSize.width != lastSize.width || curSize.height != lastSize.height)
        {
            [self reinitLightsAfterResize:self.frame];
        }
    }
}

-(void)reinitLightsAfterResize:(CGRect)frame
{
    isResizing = TRUE;
    CGFloat dotHgt = frame.size.height / kJATickerNumDotsY;
    dotSize = CGSizeMake(dotHgt, dotHgt);
    
    numDotsX = frame.size.width / dotSize.width;
    
    NSUInteger numDotsXInt = (NSUInteger)numDotsX + 1;
    
    // Set up the image views
    self.imgViews = [NSMutableArray arrayWithCapacity:numDotsXInt];
    
    CGFloat leftOffset = 0;
    for (NSUInteger i = 0; i < numDotsXInt; i++)
    {
        NSMutableArray* colViews = [NSMutableArray arrayWithCapacity:kJATickerNumDotsY];
        CGFloat topOffset = 0;
        for (NSUInteger j = 0; j < kJATickerNumDotsY; j++)
        {
            UIImage* image = [self loadImageForDot:NO atX:i andY:j];
            UIImageView* v = [[UIImageView alloc] initWithImage:image];
            [v setFrame:CGRectMake(leftOffset, topOffset, dotSize.width, dotSize.height)];
            [self addSubview:v];
            [colViews addObject:v];
            topOffset += dotSize.height;
        }
        
        leftOffset += dotSize.width;
        [imgViews addObject:colViews];
    }
    isResizing = FALSE;
    self.lastViewSize = [NSValue valueWithCGSize:frame.size];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self)
    {
        [self initMethod:self.frame];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initMethod:frame];
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
    NSUInteger charLen = kDotCharWidth;
    if ([testStr length] > charIndex)
    {
        nextChar = [testStr substringWithRange:NSMakeRange(charIndex, 1)];
        if ([nextChar isEqualToString:@"*"] || [nextChar isEqualToString:@"|"])
        {
            charLen = 1;
        }
        charIndex++;
    }

    JATickerChar* chr = [self lookupDigitizedCharacter:nextChar];
    
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
            for (NSUInteger j = 1; j < (kJATickerNumDotsY-1); j++)
            {
                UIImageView* v = (UIImageView*)[colViews objectAtIndex:j];
                
                if ([chr shouldLightDot:xOffInChar andY:(j-1)])
                {
                    UIImage* image = [self loadImageForDot:YES atX:i andY:(j-1)];
                    [v setImage:image];
                    //NSLog(@"Lit %d %d", i, j);
                }
                else
                {
                    UIImage* image = [self loadImageForDot:NO atX:i andY:(j-1)];
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
            charLen = kDotCharWidth;
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
            chr = [self lookupDigitizedCharacter:nextChar];
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

/**
 * Move the ticker string forward by one space.
 **/
- (BOOL)decrTickerStr
{
    BOOL didUpdate = NO;
    if ([curTickerStr characterAtIndex:0] == ' ')
    {
        if ([curTickerStr length] > 1)
        {
            self.curTickerStr = [curTickerStr substringFromIndex:1];
            didUpdate = YES;
        }
    }
    else if ([curTickerStr length] > 2)
    {
        self.curTickerStr = [curTickerStr substringFromIndex:2];
        didUpdate = YES;
    }
    
    if (didUpdate)
    {
        reportedDataLength++;
        
        if (self.delegate != nil && [delegate respondsToSelector:@selector(tickerView:tickerReachedPosition:)] && reportedDataLength < fedDataLength)
        {
            [delegate tickerView:self tickerReachedPosition:reportedDataLength];
        }
    }
    return didUpdate;
}

/*
 * Put the pipe characters in between the characters to space out the ticker characters by one LED light
 */
-(NSString*)formatTickerString:(NSString*)inputIn
{
    NSString* input = [inputIn uppercaseString];
    NSMutableString* res = [NSMutableString stringWithCapacity:([input length]*2)];
    for (int i = 0; i < ([input length]-1); i++)
    {
        [res appendString:[input substringWithRange:NSMakeRange(i, 1)]];
        [res appendString:@"|"];
    }
    [res appendString:[input substringWithRange:NSMakeRange([input length]-1, 1)]];
    return res;
}

/**
 * If the ticker has data, use it. Otherwise, call the delegate method to get more data
 **/
- (BOOL)checkAndPrefetchTickerData
{
    if ([[self curTickerStr] length] < kTickerThresholdToRequestMoreData)
    {
        if (self.delegate != nil && [delegate respondsToSelector:@selector(tickerView:tickerDataAtEnd:)])
        {
            NSString* data = [self.delegate tickerView:self tickerDataAtEnd:self.fedDataLength];
            if (data != nil && [data length] > 0)
            {
                fedDataLength += [data length];
                self.curTickerStr = [curTickerStr stringByAppendingString:[self formatTickerString:data]];
            }
        }
        else
        {
            NSLog(@"WARNING: Must implement delegate method tickerDataAtEnd to see data on the ticker");
        }
    }
    return ([[self curTickerStr] length] > 0);
}

/**
 * Advance the ticker forward
 **/
- (void)advanceAndUpdateTicker:(BOOL)firstTickAfterStart
{
    BOOL didUpdate = NO;
    
    BOOL shouldAdvanceI = !firstTickAfterStart;
    if (!isStarted)
    {
        shouldAdvanceI = FALSE;
    }
    
    if (shouldAdvanceI)
    {
        if (curDotOffset == 0 && [self checkAndPrefetchTickerData])
        {
            didUpdate = [self decrTickerStr];
            if (lastDecrChar != nil)
            {
                [self decrTickerStr];
                self.lastDecrChar = nil;
            }
        }
        else if (curDotOffset > 0)
        {
            didUpdate = YES;
        }
        
        
        if (!didUpdate)
        {
            self.curTickerStr = @" ";
            didUpdate = YES;
        }
    }
    else
    {
        didUpdate = YES;
    }
    if (isStarted)
    {
        self.lastDecrChar = [self updateTickerStr:curTickerStr andInnerDotOffset:curDotOffset];
        curDotOffset++;
        
        if (curDotOffset > 4)
        {
            curDotOffset = 0;
        }
    }
    
    NSUInteger maxLoc = 12;
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
    {
        maxLoc = 14;
    }
    
    if (didUpdate)
    {
        [self performSelector:@selector(updateTicker) withObject:nil afterDelay:self.tickDelaySeconds];
    }
    else
    {
        if ([self checkAndPrefetchTickerData])
        {
            [self performSelector:@selector(updateTicker) withObject:nil afterDelay:self.tickDelaySeconds];
        }
        else
        {
            [self stopTicker];
        }
    }
}

- (void)updateTicker
{
    [self advanceAndUpdateTicker:NO];
}

- (JATickerChar*)lookupDigitizedCharacter:(NSString*)nextChar
{
    if (nextChar == nil || [nextChar length] != 1)
    {
        return [charDict objectForKey:@" "];
    }
    
    JATickerChar* chr = [charDict objectForKey:nextChar];
    if (chr != nil)
    {
        return chr;
    }
    
    // See if the delegate can provide one, unless the delegate has already been asked
    if (self.delegate != nil &&
        [delegate respondsToSelector:@selector(tickerView:definitionForCharacter:)] &&
        ![undefinedChars containsObject:nextChar] &&
        !([nextChar isEqualToString:@"_"] || [nextChar isEqualToString:@" "]))
    {
        chr = [delegate tickerView:self definitionForCharacter:[nextChar characterAtIndex:0]];
        if (chr != nil)
        {
            // Keep it cached so the delegate does not need to be invoked again
            [charDict setObject:chr forKey:nextChar];
            return chr;
        }
        else
        {
            // Indicate that the character is not defined, to avoid asking the delegate again
            [undefinedChars addObject:nextChar];
        }
    }
    
    return [charDict objectForKey:@" "];
}

#pragma mark - Public methods

- (void)startTicker
{
    if (isStarted)
    {
        return;
    }
    curDotOffset = 0;
    isStarted = TRUE;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateTicker) object:nil];
    
    [self advanceAndUpdateTicker:YES];
}

- (void)stopTicker
{
    if (!isStarted)
    {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateTicker) object:nil];
    
    isStarted = FALSE;
}

- (void)flushCacheOfImagesForLights
{
    self.imageCache = [NSMutableDictionary dictionaryWithCapacity:kTickerImageCacheCapacity];
}

@end


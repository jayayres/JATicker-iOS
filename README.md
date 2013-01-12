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
 
JATickerView
 
A customizable LED ticker framework for iOS, as seen in the Stock Picking Darts app for
iPhone and iPad: https://itunes.apple.com/us/app/stock-picking-darts-invest/id495510614?mt=8 .

Author: Jay Ayres
Email: jaysapps10@gmail.com

Features:
  * Authentic digital LED ticker - display stock quotes, sports scores, the latest headlines,
      or more in your app- just provide the data!
  * Customize the ticker speed and light bulb colors.
  * Digital symbols for English included, with API hooks to provide localized ticker symbols in any language.
  * Customize individual ticker bulbs with your own images.
  * Compatible back to iOS 4.3.
  
Getting Started:

The quickest way to get started is to follow the sample included at:
JATickerView/samples/JATickerViewSample/JATickerViewSample.xcodeproj

Instructions to include and use the framework in your XCode project:

1. In XCode 4, select the build target for your project. Choose the Build Phases tab.
   Select Link Binary with Libraries, then press the plus sign. Press Add Other..., then
   choose JATickerView/bin/JATicker.framework , and press Open.
   
2. Select File -> Add Files to <Your Project>..., and select JATickerView/bin/JATickerResources.bundle .
   Make sure to check Copy items into destination group's folder, then click Add.
   
3. Inside of the ViewController file that you wish to use a ticker view, import <JATicker/JATicker.h>.

4. The main ticker view type is the JATickerView. You may add this view either through InterfaceBuilder or
   programmatically via code. 
   
5. Be sure to set the JATickerView's delegate to a class implementing the JATickerViewDelegate protocol. The
   most important delegate method to implement is:
   
   -(NSString*)tickerView:(JATickerView*)tickerView tickerDataAtEnd:(NSUInteger)currentLength;
   
   which returns to the ticker a string to display. This method is called whenever the ticker has run out, or
   is about to run out, of text to display. It is also called the first time after the startTicker method is invoked.
   
6. Call the startTicker method on JATickerView to start the ticker, after its delegate has been set.


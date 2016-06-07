## JATickerView
 
A customizable LED ticker framework for iOS, as seen in the Stock Picking Darts app for
iPhone and iPad: https://itunes.apple.com/us/app/stock-picking-darts-invest/id495510614?mt=8 . Written in Swift, and fully interoperable with Objective-C, supporting back to iOS 8.

Author: Jay Ayres  
Email: jaysapps10@gmail.com
  
#### Features:
  * Authentic digital LED ticker - display stock quotes, sports scores, the latest headlines,
      or more in your app- just provide the data!
  * Customize the ticker speed and light bulb colors.
  * Digital symbols for English included, with API hooks to provide localized ticker symbols in any language.
  * Customize individual ticker bulbs with your own images.
  * Written in Swift, with full Objective-C interoperability
  * Compatible back to iOS 8.
  
#### Getting Started:

The quickest way to get started is to use [CocoaPods] [1]:
[1]: https://cocoapods.org/        "CocoaPods"    
    
    gem install cocoapods
    
Specify it in your Podfile:
 
    source 'https://github.com/CocoaPods/Specs.git'
    platform :ios, '8.0'
    use_frameworks!

    target '<Your Target Name>' do
        pod 'JATickerView', '~> 2.0'
    end


Alternatively, you may import the JATickerView.xcodeproj project file into your project manually. Open up JATickerView.xcworkspace and build the JATickerViewSampleObjC or JATickerViewSampleSwift targets to see how to import the project file manually into either an Objective-C or Swift project.


### Usage of the ticker

The main ticker view type is the JATickerView. You may add this view either through InterfaceBuilder or programmatically via code. 
   
Be sure to set the JATickerView's delegate to a class implementing the JATickerViewDelegate protocol. The most important delegate method to implement is:
   
    func tickerView(tickerView: JATickerView,
                             tickerDataAtEnd currentLength: UInt) -> String
                             
   
   which returns to the ticker a string to display. This method is called whenever the ticker has run out, or is about to run out, of text to display. It is also called the first time after the startTicker method is invoked.
   
Call the startTicker method on JATickerView to start the ticker, after its delegate has been set. See the example code for more advanced usage of the ticker.


### License

JATickerView is released under the Apache 2.0 License. See LICENSE for details.



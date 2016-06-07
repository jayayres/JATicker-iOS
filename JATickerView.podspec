#
#  Be sure to run `pod spec lint JATickerView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.

Pod::Spec.new do |s|

  s.name         = "JATickerView"
  s.version      = "2.0"
  s.summary      = "Customizable scrolling LED ticker library for iPhone and iPad"

  s.description  = <<-DESC
A customizable LED ticker framework for iOS, as seen in the Stock Picking Darts app for iPhone and iPad: https://itunes.apple.com/us/app/stock-picking-darts-invest/id495510614?mt=8 . Authentic digital LED ticker - display stock quotes, sports scores, the latest headlines, or more in your app- just provide the data! Customize the ticker speed and light bulb colors. Digital symbols for English included, with API hooks to provide localized ticker symbols in any language. Customize individual ticker bulbs with your own images. Compatible back to iOS 8.0.
                   DESC

  s.homepage     = "https://github.com/jayayres/JATicker-iOS"
  s.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author             = { "jayayres" => 'jaysapps10@gmail.com' }
  s.social_media_url   = "http://twitter.com/jayayres"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/jayayres/JATicker-iOS.git", :tag => "#{s.version}" }
  s.source_files  = "Source/*.swift"
  s.resources = ['Resources/TickerImages.xcassets','Resources/symbols.txt']
end

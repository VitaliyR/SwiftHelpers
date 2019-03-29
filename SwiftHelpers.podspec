#
# Be sure to run `pod lib lint SwiftHelpers.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftHelpers'
  s.version          = '0.1.0'
  s.summary          = 'Very personal helpers for Swift'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/vitaliyr/SwiftHelpers'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'vitaliyr' => 'vit@ribachenko.com' }
  s.source           = { :git => 'https://github.com/vitaliyr/SwiftHelpers.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/sa1en'
  s.swift_version    = '5.0'

  s.ios.deployment_target = '10.0'
  
  s.source_files = 'SwiftHelpers/Base/**/*'
  
  s.subspec 'iOS' do |ss|
      ss.source_files = 'SwiftHelpers/{Base,iOS}/**/*'
      ss.ios.frameworks = 'UIKit', 'CoreData', 'CoreLocation'
  end
  
  s.default_subspecs = 'iOS'
end

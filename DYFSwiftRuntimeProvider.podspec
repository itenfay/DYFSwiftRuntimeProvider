
Pod::Spec.new do |spec|

  spec.name         = "DYFSwiftRuntimeProvider"
  spec.version      = "2.1.0"
  spec.summary      = "DYFSwiftRuntimeProvider wraps the runtime, and provides some common usages."

  spec.description  = <<-DESC
  `DYFSwiftRuntimeProvider` wraps the runtime, and can quickly use for the transformation of the dictionary and model, archiving and unarchiving, adding a method, exchanging two methods, replacing a method, and getting all the variable names, property names and method names of a class.
  DESC

  spec.homepage     = "https://github.com/itenfay/DYFSwiftRuntimeProvider"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "Tenfay" => "hansen981@126.com" }
  # Or just: spec.author    = "Tenfay"
  # spec.authors            = { "Tenfay" => "hansen981@126.com" }
  # spec.social_media_url   = "https://twitter.com/Tenfay"

  # spec.platform     = :ios
  spec.ios.deployment_target = "8.0"
  # spec.osx.deployment_target = "10.7"
  # spec.watchos.deployment_target = "2.0"
  # spec.tvos.deployment_target = "9.0"

  spec.swift_versions = ['4.2', '5.0']

  spec.source = { :git => "https://github.com/itenfay/DYFSwiftRuntimeProvider", :tag => spec.version.to_s }

  spec.source_files  = "Classes/*.swift"
  # spec.exclude_files = "Classes/Exclude"
  # spec.public_header_files = "Classes/**/*.h"
  # spec.resource  = "icon.png"
  # spec.resources = "Resources/*.png"

  # spec.framework  = "SomeFramework"
  # spec.frameworks = "SomeFramework", "AnotherFramework"

  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"

  spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"

end

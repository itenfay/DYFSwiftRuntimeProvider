
Pod::Spec.new do |spec|

  spec.name         = "DYFSwiftRuntimeProvider"
  spec.version      = "1.0.1"
  spec.summary      = "DYFSwiftRuntimeProvider wraps the runtime."

  spec.description  = <<-DESC
	DYFSwiftRuntimeProvider wraps the runtime, and can quickly use for the transformation of the dictionary and model, archiving and unarchiving, adding a method, exchanging two methods, replacing a method, and getting all the variable names, property names and method names of a class.
                   DESC

  spec.homepage     = "https://github.com/dgynfi/DYFSwiftRuntimeProvider"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  spec.license      = { :type => "MIT", :file => "LICENSE" }


  spec.author             = { "dgynfi" => "vinphy.teng@foxmail.com" }
  # Or just: spec.author    = "dgynfi"
  # spec.authors            = { "dgynfi" => "vinphy.teng@foxmail.com" }
  # spec.social_media_url   = "https://twitter.com/dgynfi"


  spec.platform     = :ios

  spec.ios.deployment_target = "8.0"
  # spec.osx.deployment_target = "10.7"
  # spec.watchos.deployment_target = "2.0"
  # spec.tvos.deployment_target = "9.0"

  spec.swift_version = "5.0"

  spec.source = { :git => "https://github.com/dgynfi/DYFSwiftRuntimeProvider.git", :tag => spec.version }


  spec.source_files  = "SwiftRuntimeProvider/*.swift"
  # spec.exclude_files = "SwiftRuntimeProvider/Exclude"

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

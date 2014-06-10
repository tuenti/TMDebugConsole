Pod::Spec.new do |s|
  s.name         = 'TMDebugConsole'
  s.version      = '0.1.0'
  s.homepage     = 'https://github.com/tuenti/TMDebugConsole'
  s.summary      = 'Simple in-app console to be used with Cocoa Lumberjack'
  s.authors      = { 'Tuenti Technologies S.L.' => 'https://twitter.com/TuentiEng' }
  s.source       = { :git => 'https://github.com/tuenti/TMDebugConsole.git', :tag => s.version.to_s }
  s.source_files = 'Classes/*.{h,m}'
  s.license      = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.requires_arc = true
end

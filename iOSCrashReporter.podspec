Pod::Spec.new do |s|
  # Trunk name must be unique — generic "CrashReporter" is already taken on CocoaPods.
  s.name             = 'iOSCrashReporter'
  s.version          = '1.0.0'
  s.summary          = 'Standalone crash capture plugin for native iOS apps.'
  s.description      = 'Capture-only crash reporting: uncaught handler, breadcrumbs, ANR/hang, signal pending files, last-crash buffer, optional host sink. No networking or credentials.'
  s.homepage         = 'https://github.com/arsarsars1/ios-crash-reporter'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'arsarsars1' => 'arsarsars1@users.noreply.github.com' }
  s.source           = { :git => 'https://github.com/arsarsars1/ios-crash-reporter.git', :tag => "v#{s.version}" }
  s.platform         = :ios, '15.0'
  s.swift_version    = '5.9'
  s.source_files     = 'Sources/CrashReporter/**/*.{swift,h,c,m}'
  s.public_header_files = 'Sources/CrashReporter/Native/CrashSignalCapture.h'
  s.frameworks       = 'UIKit'
  s.module_name      = 'CrashReporter'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
  }
end

#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint myfatoorah_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'myfatoorah_flutter'
  s.version          = '0.0.1'
  s.summary          = 'MyFatoorah Flutter Plugin.'
  s.description      = <<-DESC
  MyFatoorah Flutter Plugin.
                       DESC
  s.homepage         = 'http://myfatoorah.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'tech@myfatoorah.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'MyFatoorah', '~> 2.0.152'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end

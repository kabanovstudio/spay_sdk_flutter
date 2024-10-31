Pod::Spec.new do |s|
  s.name             = 'sber_pay_ios'
  s.version          = '1.0.0'
  s.summary          = 'Plugin for native payment service SberPay'
  s.description      = <<-DESC
SberPay plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'SPaySDK', '~> 2.2.8'
  s.platform = :ios, '13.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end

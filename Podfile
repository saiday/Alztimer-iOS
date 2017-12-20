use_frameworks!

platform :ios, '10.0'

target 'Alztimer' do
  pod 'PureLayout',                 '~> 3.0.2'
  pod 'RxSwift',                    '~> 4.0.0'
  pod 'RxCocoa',                    '~> 4.0.0'
  pod 'Firebase/Core',              '~> 3.15.0'
  pod 'AFDateHelper',               '~> 4.2.6'
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.0'
    end
  end
end

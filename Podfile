use_frameworks!

target 'AccountBook' do
    pod 'MJRefresh', '~> 3.1'
    pod 'UIImageView+Extension', '~> 0.2'
    pod 'M80AttributedLabel', '~> 1.6'
    pod 'UILabel+Copyable', '~> 1.0'
    pod 'Grouper', '~> 1.0' #:path => '/Users/limeng/Documents/Xcode/Grouper'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.1'
        end
    end
end

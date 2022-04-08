platform :ios, '14.0'

target 'MementoFM' do
  use_frameworks!
  inhibit_all_warnings!



end


post_install do |installer|
  installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        if config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] == '8.0'
            config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = '9.0'
        end
      end
  end
end
platform :ios, '14.0'

target 'MementoFM' do
  use_frameworks!
  inhibit_all_warnings!

  # Pods for MementoFM
  pod 'RealmSwift'

  target 'MementoFMTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'Nimble'
    pod 'RealmSwift'
  end

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
platform :ios, '9.0'
use_frameworks!

target 'Muhlag' do
	pod "Material"
	pod "DZNEmptyDataSet"
	pod "Alamofire"
	pod 'SwiftyJSON'
    pod "Tabman"
	pod "RevealingSplashView"
	pod "Kingfisher"
	pod "EasyAnimation"	
	pod "CocoaBar"
    pod 'RealmSwift'
    pod "MMLoadingButton"
    pod 'BubbleTransition', '~> 2.0.0'
    pod 'AMPopTip'
    pod 'DGElasticPullToRefresh'

pod 'INSPersistentContainer'

    pod 'IQKeyboardManagerSwift'
    pod 'SwiftValidator', :git => 'https://github.com/jpotts18/SwiftValidator.git', :branch => 'master'
 
end


post_install do |installer|
 installer.pods_project.targets.each do |target|
   target.build_configurations.each do |config|
     config.build_settings['SWIFT_VERSION'] = '3.0'
   end
 end
end

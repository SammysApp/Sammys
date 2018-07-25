
# Ignore all warnings from all pods
inhibit_all_warnings!

def shared_pods
  pod 'Alamofire'
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'CodableFirebase'
  pod 'PromiseKit'
  pod 'PromiseKit/Alamofire'
  pod 'SwiftySound'
end
  
# Pods for Sammys
target 'Sammys' do
  use_frameworks!
  
  shared_pods
  pod 'Firebase/Auth'
  pod 'Stripe'
  pod 'FBSDKLoginKit'
  pod 'NVActivityIndicatorView'
end

target 'Sammys Kitchen' do
  use_frameworks!
  
  shared_pods
end

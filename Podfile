
# Ignore all warnings from all pods
inhibit_all_warnings!

def shared_pods
  pod 'PromiseKit'
  pod 'PromiseKit/Alamofire'
  pod 'Alamofire'
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'CodableFirebase'
end
  
target 'Sammys' do
  use_frameworks!
  shared_pods
  pod 'Firebase/Auth'
  pod 'Stripe'
  pod 'FBSDKLoginKit'
end

target 'Sammys Kitchen' do
  use_frameworks!
  shared_pods
  pod 'SwiftySound'
end

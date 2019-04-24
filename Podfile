# Ignore all warnings from all pods
inhibit_all_warnings!

platform :ios, '11.0'

target 'Sammys' do
  use_frameworks!
  pod 'PromiseKit'
  pod 'PromiseKit/Foundation'
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'SquareInAppPaymentsSDK'
  pod 'TinyConstraints'
  
  target 'SammysTests' do
    use_frameworks!
    inherit! :complete
  end
end

target 'Kitchen' do
  use_frameworks!
  pod 'PromiseKit'
  pod 'PromiseKit/Foundation'
  pod 'Starscream'
  pod 'TinyConstraints'
end
  

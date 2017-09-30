Pod::Spec.new do |s|
  s.name     = 'Apex'
  s.version  = '3.0.0'
  s.ios.deployment_target = '9.3'
  s.license  =  { :type => 'MIT', :file => 'LICENSE' }
  s.summary  = 'A Swift model management library with async capability built in.'
  s.homepage = 'https://github.com/dtartaglia/Apex'
  s.authors   = { 'Daniel Tartaglia' => 'danielt1263@gmail.com' }
  s.source   = { :git => 'https://github.com/dtartaglia/Apex.git', :tag => s.version.to_s }

  s.description = 'A model/state management library inspired by Redux but with async capability built into the model through the use of Command objects.'

  s.source_files = 'Apex/*.swift'
  s.framework    = 'Foundation'
  s.requires_arc = true
end

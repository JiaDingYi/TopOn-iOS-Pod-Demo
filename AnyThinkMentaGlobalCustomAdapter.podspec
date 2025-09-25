Pod::Spec.new do |s|
  s.name             = 'AnyThinkMentaGlobalCustomAdapter'
  s.version          = '1.0.22'
  s.summary          = 'AnyThinkMentaGlobalCustomAdapter.'
  s.description      = 'A short description of AnyThinkMentaGlobalCustomAdapter'
  s.homepage         = 'https://github.com/jdy/TopOnDemo-global'
  s.license          = "Custom"
  s.author           = { 'jdy' => 'wzy2010416033@163.com' }
  s.source           = { :git => "https://github.com/JiaDingYi/TopOn-iOS-Pod-Demo.git", :tag => "#{s.version}"}

  s.static_framework = true
  s.ios.deployment_target = '11.0'
  s.source_files = 'TPNMentaCustomAdapter/Classes/**/*'
  
  s.dependency 'AnyThinkiOS'
  s.dependency 'MentaBaseGlobal', '~> 1.0.22'
  s.dependency 'MentaMediationGlobal', '~> 1.0.22'
  s.dependency 'MentaVlionGlobal', '~> 1.0.22'
  s.dependency 'MentaVlionGlobalAdapter', '~> 1.0.22'

end

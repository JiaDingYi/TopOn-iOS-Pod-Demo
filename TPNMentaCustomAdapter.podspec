Pod::Spec.new do |s|
  s.name             = 'TPNMentaCustomAdapter'
  s.version          = '0.1.0'
  s.summary          = 'TPNMentaCustomAdapter.'
  s.description      = 'A short description of TPNMentaCustomAdapter'
  s.homepage         = 'https://github.com/jdy/TopOnDemo-global'
  s.license          = "Custom"
  s.author           = { 'jdy' => 'wzy2010416033@163.com' }
  s.source           = { :git => 'https://github.com/jdy/TopOnDemo-global.git', :tag => s.version.to_s }

  s.static_framework = true
  s.ios.deployment_target = '11.0'
  s.source_files = 'TPNMentaCustomAdapter/Classes/**/*'
  
  s.dependency 'TPNiOS', '~> 6.3.54'
  s.dependency 'MentaBaseGlobal', '1.0.4'
  s.dependency 'MentaMediationGlobal', '1.0.4'
  s.dependency 'MentaVlionGlobal', '1.0.4'
  s.dependency 'MentaVlionGlobalAdapter', '1.0.4'

end
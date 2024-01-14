Pod::Spec.new do |s|
  s.name = 'RelatedDB'
  s.version = '1.1.6'
  s.license = 'MIT'

  s.summary = 'RelatedDB is a lightweight Swift wrapper around SQLite.'
  s.homepage = 'https://relatedcode.com'
  s.author = { 'Related Code' => 'info@relatedcode.com' }

  s.source = { :git => 'https://github.com/relatedcode/RelatedDB.git', :tag => s.version }
  s.source_files = 'RelatedDB/Sources/**/*.swift'

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }

  s.swift_version = '5.0'

  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'

  s.requires_arc = true
end

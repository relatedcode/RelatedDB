Pod::Spec.new do |s|
  s.name = 'RelatedDB'
  s.version = '1.0.7'
  s.license = { :type => 'Copyright', :file => 'LICENSE' }

  s.summary = 'RelatedDB is a lightweight Swift wrapper around SQLite.'
  s.homepage = 'https://relatedcode.com'
  s.author = { 'Related Code' => 'info@relatedcode.com' }

  s.source = { :git => 'https://github.com/relatedcode/RelatedDB.git', :tag => s.version }

  s.ios.vendored_frameworks = 'RelatedDB.xcframework'

  s.platform = :ios, '13.0'

  s.requires_arc = true
end

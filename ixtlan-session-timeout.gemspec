# -*- mode: ruby -*-
Gem::Specification.new do |s|
  s.name = 'ixtlan-session-timeout'
  s.version = '0.1.0'

  s.summary = 'idle session timeout on a per controller base'
  s.description = 'idle session timeout for rails on a per controller base'
  s.homepage = 'http://github.com/mkristian/ixtlan-session-timeout'

  s.authors = ['mkristian']
  s.email = ['m.kristian@web.de']

  s.files = Dir['MIT-LICENSE']
  s.licenses << 'MIT-LICENSE'
#  s.files += Dir['History.txt']
  s.files += Dir['README.textile']
#  s.extra_rdoc_files = ['History.txt','README.textile']
  s.rdoc_options = ['--main','README.textile']
  s.files += Dir['lib/**/*']
  s.files += Dir['spec/**/*']
  s.test_files += Dir['spec/**/*_spec.rb']
  s.add_development_dependency 'rspec', '2.4.0'
  s.add_development_dependency 'rake', '0.8.7'
end

# vim: syntax=Ruby

Gem::Specification.new do |s|
  s.name        = 'apache_authtkt'
  s.version     = '2.0.0'
  s.license     = 'Apache v2'
  s.date        = '2015-07-29'
  s.rubyforge_project = 'nowarning'
  s.summary     = 'Ruby client for mod_auth_tkt'
  s.description = 'Ruby client for mod_auth_tkt. See http://www.openfusion.com.au/labs/mod_auth_tkt/'
  s.authors     = ['William Johnston', 'Peter Karman']
  s.email       = 'wjohnston@mpr.org'
  s.homepage    = 'https://github.com/APMG/apache-authtkt-ruby'
  s.files       = ['lib/apache_authtkt.rb']
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
end

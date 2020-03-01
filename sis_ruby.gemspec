require File.join(File.dirname(__FILE__), 'lib', 'sis_ruby', 'version')

Gem::Specification.new do |s|
  s.name              = 'sis_ruby'
  s.version           = SisRuby::VERSION
  s.platform          = Gem::Platform::RUBY
  s.authors           = ['Keith Bennett', 'Neel Goyal']
  s.email             = ['keithrbennett@gmail.com', 'sis-dev@verisign.com']
  s.homepage          = 'https://github.com/keithrbennett/sis_ruby'
  s.summary           = 'SIS Ruby Client'
  s.description       = s.summary
  s.files             = `git ls-files`.split($/)
  s.require_path      = 'lib'
  s.license           = 'BSD 3-Clause'

  s.add_dependency 'awesome_print', '>= 1.6.0'
  s.add_dependency 'trick_bag', '>= 0.63.1'
  s.add_dependency 'typhoeus', '>= 0.8.0'

  s.add_development_dependency "rake", ">= 12.3.3"
  s.add_development_dependency 'rspec', '>= 3.0'
end

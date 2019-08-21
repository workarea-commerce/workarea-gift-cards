$LOAD_PATH.push File.expand_path('../lib', __FILE__)

require 'workarea/gift_cards/version'

Gem::Specification.new do |s|
  s.name        = 'workarea-gift_cards'
  s.version     = Workarea::GiftCards::VERSION
  s.authors     = ['bcrouse']
  s.email       = ['bcrouse@workarea.com']
  s.homepage    = 'https://github.com/workarea-commerce/workarea-gift-cards'
  s.summary     = 'Gift Cards plugin for the Workarea Commerce Platform'
  s.description = 'Adds built-in digital gift cards to the Workarea Commerce Platform.'

  s.files = `git ls-files`.split("\n")

  s.license = 'Business Software License'

  s.required_ruby_version = '>= 2.3.0'

  s.add_dependency 'workarea', '~> 3.x', '>= 3.5.x'
end

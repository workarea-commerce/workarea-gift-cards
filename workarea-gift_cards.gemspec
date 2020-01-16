$LOAD_PATH.push File.expand_path('../lib', __FILE__)

require 'workarea/gift_cards/version'

Gem::Specification.new do |s|
  s.name        = 'workarea-gift_cards'
  s.version     = Workarea::GiftCards::VERSION
  s.authors     = ['bcrouse']
  s.email       = ['bcrouse@weblinc.com']
  s.homepage    = 'https://github.com/workarea-commerce/workarea-gift-cards'
  s.summary     = 'Gift Cards plugin for the Workarea commerce platform'
  s.description = 'Adds built-in gift cards to the Workarea commerce platform.'

  s.files = `git ls-files`.split("\n")

  s.license = 'Business Software License'

  s.required_ruby_version = '>= 2.3.0'

  s.add_dependency 'workarea', '~> 3.3.0'
end

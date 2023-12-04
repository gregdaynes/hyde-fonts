require File.expand_path('../lib/hyde_fonts.rb', __FILE__)

Gem::Specification.new do |s|
  s.name = "hyde-fonts"
  s.version = Hyde::Fonts::VERSION
  s.summary = "Plugin for jekyll to manage google fonts"
  s.description = "Hyde Fonts is a plugin for Jekyll to make adding Google fonts based on configuration."
  s.authors = ["Gregory Daynes"]
  s.email   = "email@gregdaynes.com"
  s.homepage = "https://gregdaynes.com"
  s.license = "MIT"

  s.files = Dir["{lib}/**/*.rb"]
  s.require_path = 'lib'

  s.add_development_dependency "jekyll", ">= 4.0", "< 5.0"
end

# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/core_extended/version"

Gem::Specification.new do |s|
  s.version = Decidim::CoreExtended.version
  s.authors = ["Paulina Kamińska"]
  s.email = ["paulina.kaminska@codeshine.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-core_extended"
  s.required_ruby_version = ">= 2.7"

  s.name = "decidim-core_extended"
  s.summary = "A decidim core_extended module"
  s.description = "Engine extending decidim core module functionalities."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::CoreExtended.version
end

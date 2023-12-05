# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/processes_extended/version"

Gem::Specification.new do |s|
  s.version = Decidim::ProcessesExtended.version
  s.authors = ["Przemad"]
  s.email = ["przemyslaw.adamowicz@codeshine.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-processes_extended"
  s.required_ruby_version = ">= 2.7"

  s.name = "decidim-processes_extended"
  s.summary = "A decidim processes_extended module"
  s.description = "."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::ProcessesExtended.version
end

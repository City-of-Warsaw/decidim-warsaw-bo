# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/projects/version"

Gem::Specification.new do |s|
  s.version = Decidim::Projects.version
  s.authors = ["Paulina Kamińska"]
  s.email = ["paulina.kaminska@energydatalab.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-projects"
  s.required_ruby_version = ">= 2.7"

  s.name = "decidim-projects"
  s.summary = "A decidim projects module"
  s.description = "Component mixing functions of proposals, budgets and accountabilities."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::Projects.version
end

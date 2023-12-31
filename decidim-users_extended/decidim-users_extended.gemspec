$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "decidim/users_extended/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "decidim-users_extended"
  spec.version     = Decidim::UsersExtended::VERSION
  spec.authors     = ["Paulina Kamińska"]
  spec.email       = ["paulina.kaminska@codeshine.com"]
  spec.summary     = "Summary of Decidim::UsersExtended."
  spec.description = "Description of Decidim::UsersExtended."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"]
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "decidim-core", '0.24.3'
  spec.add_dependency "decidim-assemblies", '0.24.3'
  spec.add_dependency "rails", "~> 5.2.6"

  spec.add_development_dependency "sqlite3"
end

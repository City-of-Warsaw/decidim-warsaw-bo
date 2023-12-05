# frozen_string_literal: true

### factories
# require "decidim/faker/localized"
require 'decidim/users_extended/test/factories'
require 'decidim/core/test/factories'
require 'decidim/admin/test'
require 'decidim/assemblies/test/factories'
require 'decidim/participatory_processes/test/factories'
require 'decidim/comments/test/factories'
require 'decidim/meetings/test/factories'
require 'decidim/admin_extended/test/factories'
require 'decidim/projects/test/factories'
require 'decidim/processes_extended/test/factories'

### contexts
require 'decidim/core/test/shared_examples/admin_log_presenter_examples'

# copied from decidim-pages - was not available from outside
FactoryBot.define do
end

# def age_ranger_arr
#   Decidim::User.const_get(:AGE_RANGES)
# end

def genders_arr
  Decidim::User.const_get(:GENDERS)
end

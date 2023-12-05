# frozen_string_literal: true

module Decidim
  module AdminExtended
    module Admin
      # A form object to update admin_comment_name for AD Users.
      class AdminUserForm < Form
        mimic :user

        attribute :admin_comment_name, String
      end
    end
  end
end

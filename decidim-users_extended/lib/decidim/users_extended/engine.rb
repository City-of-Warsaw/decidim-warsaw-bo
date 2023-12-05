# frozen_string_literal: true

module Decidim
  module UsersExtended
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::UsersExtended

      routes do
        # scope '/admin' do
          get 'login-by-warszawa19115',       controller: 'sessions', action: 'peum_login', as: :peum_login
          get 'auth/warszawa19115/callback',  controller: 'sessions', action: 'peum_callback'
          get 'adlogin',  controller: 'sessions', action: 'new'
          get 'sign-in',  controller: 'sessions', action: 'new'
          post 'login',   controller: 'sessions', action: 'create'
        # end
      end

      initializer "decidim_projects.assets" do |app|
        app.config.assets.precompile += %w[admin/decidim_projects_manifest.js
                                           decidim/users_extended/password-strength.js]
      end

      initializer "decidim_users_extended.append_routes", after: :load_config_initializers do |_app|
        Rails.application.routes.append do
          mount Decidim::UsersExtended::Engine => "/"
        end
      end

      config.autoload_paths << File.join(
        Decidim::UsersExtended::Engine.root, "app", "decorators", "{**}"
      )

      # make decorators available to applications that use this Engine
      config.to_prepare do
        Dir.glob(Decidim::UsersExtended::Engine.root + "app/decorators/**/*_decorator*.rb").each do |c|
          require_dependency(c)
        end
      end
    end
  end
end

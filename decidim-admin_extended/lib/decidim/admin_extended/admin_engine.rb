# frozen_string_literal: true

module Decidim
  module AdminExtended
    # This is the engine that runs on the public interface of `AdminExtended`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::AdminExtended::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        scope :admin, path: 'admin' do
          resources :departments, controller: 'departments'
          resources :recipients, controller: 'recipients', except: :destroy
          resources :banned_words, controller: 'banned_words'
          resources :mail_templates, controller: 'mail_templates'
          resources :normal_users, controller: 'normal_users', only: [:new, :create, :edit, :update]
          resources :comments, controller: 'comments', only: :index do
            put :hide, on: :member
            collection do
              get :export
            end
          end
          resources :documents, controller: 'documents', except: :show
          resources :folders, controller: 'folders', except: [:index, :show]
          resources :budget_info_positions, except: :show
          resources :budget_info_groups, except: [:index, :show]
          resources :faqs, except: :show
          resources :faq_groups, except: [:index, :show]
          resources :contact_info_positions, except: :show
          resources :contact_info_groups, except: [:index, :show]
        end
      end

      initializer "decidim_admin_extended.append_routes", after: :load_config_initializers do |_app|
        Decidim::Admin::Engine.routes.prepend do
          scope :logs do
            get 'export' => 'logs#export', as: :export_logs
          end
          scope :users do
            get 'export' => 'users#export', as: :export_users
            get ':id/edit' => 'users#edit', as: :edit_user
            patch ':id' => 'users#update', as: :update_user
            patch ':id/activate_ad' => 'users#activate_ad', as: :activate_ad
            patch ':id/deactivate_ad' => 'users#deactivate_ad', as: :deactivate_ad
          end
          scope :officializations do
            get 'export' => 'officializations#export', as: :export_officializations
            patch ':id/remind_password' => 'officializations#remind_password', as: :remind_password_officialization
          end
        end

        Rails.application.routes.append do
          mount Decidim::AdminExtended::AdminEngine => "/"
        end
      end

      initializer "decidim_admin.admin_settings_menu" do
        Decidim.menu :admin_settings_menu do |menu|
          menu.item I18n.t("menu.departments", scope: "decidim.admin"),
                    decidim_admin_extended_admin.departments_path,
                    position: 2,
                    if: allowed_to?(:update, :organization, organization: current_organization),
                    active: is_active_link?(decidim_admin_extended_admin.departments_path)
          menu.item "Potencjalni odbiorcy", decidim_admin_extended_admin.recipients_path, position: 3
          menu.item "Szablony maili", decidim_admin_extended_admin.mail_templates_path, position: 4
          menu.item "Wulgaryzmy", decidim_admin_extended_admin.banned_words_path, position: 5
        end
      end

      initializer "decidim_admin.menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("decidim.admin.menu.comments"),
                    decidim_admin_extended_admin.comments_path,
                    icon_name: "comment-square",
                    position: 4.3,
                    active: is_active_link?(decidim_admin_extended_admin.comments_path),
                    if: current_user.ad_admin?
        end
      end

      initializer "decidim_admin.menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("decidim.admin.menu.documents"),
                    decidim_admin_extended_admin.documents_path,
                    icon_name: "file",
                    position: 4.5,
                    active: is_active_link?(decidim_admin_extended_admin.documents_path) || is_active_link?(decidim_admin_extended_admin.folders_path),
                    if: current_user.has_ad_role?
        end
      end

      # make decorators autoload in development env
      config.autoload_paths << File.join(
        Decidim::AdminExtended::AdminEngine.root, "app", "decorators", "{**}"
      )

      # make decorators available to applications that use this Engine
      config.to_prepare do
        Dir.glob(Decidim::AdminExtended::AdminEngine.root + "app/decorators/**/*_decorator*.rb").each do |c|
          require_dependency(c)
        end
      end

      def load_seed
        nil
      end
    end
  end
end

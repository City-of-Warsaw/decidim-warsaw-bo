# frozen_string_literal: true

module Decidim
  module ProcessesExtended
    # This is the engine that runs on the public interface of `ProcessesExtended`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::ProcessesExtended::Admin

      paths['db/migrate'] = nil
      paths['lib/tasks'] = nil

      routes do
        # Add admin engine routes here
        # resources :processes_extended do
        #   collection do
        #     resources :exports, only: [:create]
        #   end
        # end
        # root to: "processes_extended#index"
      end

      initializer 'decidim_processes_extended.append_routes', after: :load_config_initializers do |_app|
        Decidim::ParticipatoryProcesses::AdminEngine.routes.prepend do
          resources :participatory_processes, only: [], param: :slug, path: 'processes' do
            get 'start-voting', on: :member, as: :start_voting
          end
          scope :participatory_processes, param: :participatory_process_slug do
            get ':participatory_process_slug/endorsement_list_settings' => '/decidim/processes_extended/admin/endorsement_lists_settings#index', as: :endorsement_list_setting
            get ':participatory_process_slug/endorsement_list_settings/edit' => '/decidim/processes_extended/admin/endorsement_lists_settings#edit', as: :endorsement_list_setting_edit
            patch ':participatory_process_slug/endorsement_list_settings' => '/decidim/processes_extended/admin/endorsement_lists_settings#update', as: :endorsement_list_setting_update
          end
        end
      end

      # make decorators autoload in development env
      config.autoload_paths << File.join(
        Decidim::ProcessesExtended::AdminEngine.root, 'app', 'decorators', '{**}'
      )

      # make decorators available to applications that use this Engine
      config.to_prepare do
        Dir.glob(Decidim::ProcessesExtended::AdminEngine.root + 'app/decorators/**/*_decorator*.rb').each do |c|
          require_dependency(c)
        end
      end

      def load_seed
        nil
      end
    end
  end
end

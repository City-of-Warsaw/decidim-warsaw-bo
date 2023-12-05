# frozen_string_literal: true

module Decidim
  module Projects
    # This is the engine that runs on the public interface of `Projects`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Projects::Admin

      paths['db/migrate'] = nil
      paths['lib/tasks'] = nil

      routes do
        # Add admin engine routes here
        resources :attachments, only: :show
        resources :appeals, except: :destroy
        resources :implementations do
          get :export, on: :collection
        end
        resources :votes_cards do
          collection do
            patch :verify
            get :export
            get :export_anonymous
            get :export_for_verification
            get 'fetch-projects-via-scope'
            post :resend_all_voting_emails
          end

          member do
            get :status
            post :change_status
            get :get_voting_link
            post :resend_email
            get :publish
          end
        end
        resources :voting_lists, only: [:index] do
          post :generate_voting_numbers, on: :collection
          collection do
            post :generate_voting_numbers
            get :export
            get :export_voting_card
          end
        end

        resources :drawing_projects_logs, only: :show
        resources :ranking_lists, only: :index do
          get :export, on: :member
          collection do
            post :generate_ranks
            post :clear_vote_cards
            post :publish
          end
        end

        resources :projects do
          collection do
            scope :export, as: :export, controller: :exports do
              get :projects
              get :authors
              get :full
            end
            post :accept_changes
            post :accept_evaluations
            post :assign_to_valuator
            post :forward_to_department
            post :remind_about_drafts
            post :remind_about_missing_evaluations
            post :notify_authors_about_evaluation_results
            post :notify_authors_about_all_evaluation_results
            post :send_messages
            post :mark_conflicts
            post :erase_user_data
            post :register_all_to_signum
          end
          member do
            get :status
            post :register_to_signum
            post :change_status
            get :new_message
            post :send_message
            post :accept_coautorship
            post :notify_authors_about_evaluation_result
            resources :messages, only: %i[new create]
          end

          resources :project_conflicts, only: %i[index edit update]
          resources :votes_cards, only: :index

          resources :attachments, only: [], controller: 'implementations' do
            member do
              get :edit_alt
              patch :alt
            end
          end
          resources :appeals
          resources :formal_evaluations, except: [:index]
          resources :meritorical_evaluations, except: [:index]
          resources :evaluations do
            collection do
              get 'finish-admin-draft'
              get 'return-admin-draft'
              get 'publish-project'
              get 'finish-formal'
              get 'accept-formal'
              get 'finish-meritorical'
              get 'accept-meritorical'
              get 'finish-project-verification'
              get 'add-note-for-verificator'

              get 'choose_department'
              get 'choose_verificator'
              get 'choose_user'
              get 'choose_new_verificator'
              get 'remove_verificator'
              get 'remove_sub_coordinator'
              get 'add_return_reason'
              post 'forward_to_department'
              post 'forward_to_user'
              post 'return-to-verificator'
              post 'change_verificator'
              post 'return-to-department'
              post 'submit-for-meritorical'
              post 'submit-for-formal'
            end
          end
          resources :reevaluations do
            collection do
              get 'finish-appeal-draft'
              get 'accept-paper-appeal'
              get 'finish-appeal-verification'
              get 'finish-reevaluation'
              get 'submit-to-organization-admin'
              get 'return-from-admin-to-coordinators'
              get 'accept-coordinator-reevaluation'
              get 'choose-verificator'

              post 'submit-for-verification'
            end
          end
          #   collection do
          #     resources :exports, only: [:create]
          #   end
        end
        root to: 'projects#index'
      end

      initializer 'decidim_projects.admin_assets' do |app|
        app.config.assets.precompile += %w[admin/decidim_projects_manifest.js
                                           decidim/projects/admin/jquery.compare_text.js
                                           decidim/projects/locations-map.js.erb
                                           decidim/projects/admin/application.css
                                           decidim/projects/admin/jquery.MultiFile.js]
      end

      def load_seed
        nil
      end
    end
  end
end

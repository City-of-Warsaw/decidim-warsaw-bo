# frozen_string_literal: true

module Decidim
  module Projects
    module AdminLog
      # This class holds the logic to present a `Decidim::Projects::VoteCard`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    VotePresenter.new(action_log, view_helpers).present
      class VoteCardPresenter < Decidim::Log::BasePresenter
        private

        # Private: returns presenter of the resource
        def resource_presenter
          @resource_presenter ||= Decidim::Projects::Log::ResourcePresenter.new(action_log.resource, h, action_log.extra['resource'])
        end

        # Private: defines all the fields that are supposed to be mapped in diff
        # returns Hash
        def diff_fields_mapping
          {
            status: :string,
            scope_id: :scope,
            # district_projects: :district_projects,
            # voter data
            first_name: :string,
            last_name: :string,
            email: :string,
            street: :string,
            street_number: :string,
            flat_number: :string,
            zip_code: :string,
            city: :string,
            pesel_number: :string,
            # editor fields
            identity_confirmed: :boolean,
            card_signed: :boolean,
            data_unreadable: :boolean,
            card_invalid: :boolean,
            projects_in_districts_scope: :hash,
            projects_in_global_scope: :hash,
            card_received_late: :boolean
          }
        end

        def i18n_params
          {
            user_name: user_presenter.present,
            resource_name: resource_presenter.try(:present),
            space_name: space_presenter.present,
            diff: has_diff? ? prepare_list_attributes(changeset) : ''
          }
        end

        def prepare_list_attributes(changeset)
          changeset.map { |change| change[:attribute_name] }
                   .map { |val| "<i>'" + I18n.t(val, scope: 'activemodel.attributes.vote_card') + "'</i>" }.join(', ')
        end

        def present_content
          h.content_tag(:div, class: "logs__log__content") do
            present_log_date + present_explanation
          end
        end

        # Private: method returns translation for the given action
        def action_string
          case action
          when 'create', 'update', 'publish', 'export', 'change_status', 'voting_index',
            'show_single_vote',
            'get_link_for_vote',
            'resend_email_vote',
            'export_votes_to_csv_xlsx',
            'export_votes_for_verification',
            'publish_ranking_list',
            'resend_all_voting_email',
            'resend_voting_email',
            'get_link_for_vote',
            'verify_votes'

            "decidim.projects.admin_log.votes.#{action}"
          else
            super
          end
        end

        # Private: translation scope
        def i18n_labels_scope
          'activemodel.attributes.vote'
        end

        def diff_actions
          super + %w[create update publish change_status]
        end
      end
    end
  end
end

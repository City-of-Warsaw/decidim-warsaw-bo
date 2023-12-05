# frozen_string_literal: true

module Decidim
  module Projects
    # This job is used to queue all the mails connected to evaluation of the project.
    class EvaluationJob < ApplicationJob
      include Decidim::EmailChecker

      queue_as :events

      def perform(project, action, action_initiator, object_with_receivers)
        receivers = case action
                    when 'finish_admin_draft', 'finish_formal', 'formal_accepted', 'finish_meritorical', 'meritorical_accepted'
                      # object_with_receivers is a department
                      # we need all it's coordinators
                      object_with_receivers.coordinators
                    when 'draft_reminder'
                      # object_with_receivers is an actual_edition
                      # we need all all projects from it to retrieve authors
                      # not used: decidim-projects/app/commands/decidim/projects/admin/remind_draft.rb
                      Decidim::Projects::Project.where(edition_year: object_with_receivers.edition_year).all.map { |proj| proj.authors.first }
                    end


        if action == 'finish_meritorical'
          mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'meritorical_finished')
          return unless mail_template&.filled_in?

          receivers.each do |user|
            # all of those emails MUST be sent
            # return unless action_receiver.email_on_notification
            next unless valid_email?(user.email)

            ProjectMailer.notify_from_template(project, user, mail_template).deliver_later
          end
        else
          receivers.each do |user|
            # all of those emails MUST be sent
            # return unless action_receiver.email_on_notification
            next unless valid_email?(user.email)

            EvaluationMailer.notify(project, action, action_initiator, user).deliver_later
          end
        end
      end
    end
  end
end

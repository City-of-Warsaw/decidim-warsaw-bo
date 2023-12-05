# frozen_string_literal: true

module Decidim
  module Projects
    module Admin::Evaluation
      # A command with all the business logic when a user publishes project.
      class PublishProject < Rectify::Command

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(project, current_user)
          @project = project
          @current_user = current_user
          @action = 'publish_project'
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless project.state == Decidim::Projects::Project::ADMIN_POSSIBLE_STATES[0]
          return broadcast(:invalid) unless project.verification_status == Decidim::Projects::Project::VERIFICATION_STATES::WAITING

          transaction do
            publish_paper_project
            send_notification
          end
          broadcast(:ok, project)
        end

        # private

        attr_reader :project, :action, :current_user

        def publish_paper_project
          @project = Decidim.traceability.perform_action!(
            :publish,
            project,
            current_user,
            visibility: "admin-only"
          ) do
            project.update(project_attributes)
            # project.set_visible_version # nie tworzymy publicznie widocznej wersji na publikację
            project.save(validate: false)
            project
          end
        end

        def project_attributes
          {
            evaluator: nil, # clearing
            # publishing
            # verification_status: Decidim::Projects::Project::VERIFICATION_STATES::WAITING, # not changing, coordinator still needs to pass it further
            state: 'published',
            published_at: Time.current,
            esog_number: Project.generate_esog(@project.participatory_space)
          }
        end

        def author
          project.creator_author
        end

        def send_notification
          project.reload

          # author
          mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'author_invitation_email_template')
          Decidim::Projects::TemplatedMailerJob.perform_later(project, project.creator_author, mail_template)

          # notifications for coauthors
          project.coauthors.each { |coauthor| invite_coauthor(coauthor) }
        end

        # private method
        #
        # Sending notifications to users about them being invited to coauthor project
        #
        # returns nothing
        def invite_coauthor(user)
          mail_template = if user.sign_in_count.zero?
                            # user that was created by system
                            Decidim::AdminExtended::MailTemplate.find_by(system_name: 'coauthor_invitation_email_template')
                          else
                            Decidim::AdminExtended::MailTemplate.find_by(system_name: 'coauthorship_confirmation_email_template')
                          end
          Decidim::Projects::TemplatedMailerJob.perform_later(project, user, mail_template)
        end
      end
    end
  end
end

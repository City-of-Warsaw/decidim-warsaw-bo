# frozen_string_literal: true

module Decidim
  module Projects
    #
    # Decorator for projects
    #
    class ProjectPresenter < SimpleDelegator
      include Rails.application.routes.mounted_helpers
      include ActionView::Helpers::UrlHelper
      include Decidim::SanitizeHelper
      include Decidim::TranslatableAttributes

      # Public: sets author for Project
      def author
        @author ||= if official?
                      Decidim::Projects::OfficialAuthorPresenter.new
                    else
                      coauthorship = coauthorships.includes(:author, :user_group).first
                      coauthorship.user_group&.presenter || coauthorship.author.presenter
                    end
      end

      # Public: sets project
      def project
        __getobj__
      end

      # Public: sets public path for the project
      def project_path
        Decidim::ResourceLocatorPresenter.new(project).path
      end

      # Public: sets link to the projects with it's title
      def display_mention
        link_to title, project_path
      end

      # Render the project title
      #
      # links - should render hashtags as links?
      # extras - should include extra hashtags?
      #
      # Returns a String.
      def title(links: false, extras: true, html_escape: false, all_locales: false)
        project.title
      end

      # Render the project id & title
      #
      # links - should render hashtags as links?
      # extras - should include extra hashtags?
      #
      # Returns a String.
      def id_and_title(links: false, extras: true, html_escape: false)
        "##{project.id} - #{title(links: links, extras: extras, html_escape: html_escape)}"
      end

      # Render the project body
      #
      # links - should render hashtags as links?
      # extras - should include extra hashtags?
      #
      # Returns a String.
      def body(links: false, extras: true, strip_tags: false, all_locales: false)
        project.body
      end

      # Returns the project VISIBLE versions
      #
      # Returns an Array.
      def versions
        version_state_published = false
        pending_state_change = nil

        project.versions.visible.map do |version|
          state_published_change = version.changeset["state_published_at"]
          version_state_published = state_published_change.last.present? if state_published_change

          if version_state_published
            version.changeset["state"] = pending_state_change if pending_state_change
            pending_state_change = nil
          end

          next if Decidim::Projects::DiffRenderer.new(version).diff.empty?

          version
        end.compact
      end

      delegate :count, to: :versions, prefix: true

      # Public: returns project manifest
      def resource_manifest
        project.class.resource_manifest
      end

      private

      # Private: sanitizes provided html list
      #
      # - text - html with unordered list
      #
      # returns String
      def sanitize_unordered_lists(text)
        text.gsub(%r{(?=.*</ul>)(?!.*?<li>.*?</ol>.*?</ul>)<li>}) { |li| "#{li}• " }
      end

      # Private: sanitizes provided html list
      #
      # - text - html with ordered list
      #
      # returns String
      def sanitize_ordered_lists(text)
        i = 0

        text.gsub(%r{(?=.*</ol>)(?!.*?<li>.*?</ul>.*?</ol>)<li>}) do |li|
          i += 1

          li + "#{i}. "
        end
      end

      # Private: sanitizes p ending tags
      #
      # returns String
      def add_line_feeds_to_paragraphs(text)
        text.gsub("</p>") { |p| "#{p}\n\n" }
      end

      # Private: sanitizes li ending tags
      #
      # returns String
      def add_line_feeds_to_list_items(text)
        text.gsub("</li>") { |li| "#{li}\n" }
      end

      # Adds line feeds after the paragraph and list item closing tags.
      #
      # Returns a String.
      def add_line_feeds(text)
        add_line_feeds_to_paragraphs(add_line_feeds_to_list_items(text))
      end

      # Maintains the paragraphs and lists separations with their bullet points and
      # list numberings where appropriate.
      #
      # Returns a String.
      def sanitize_text(text)
        add_line_feeds(sanitize_ordered_lists(sanitize_unordered_lists(text)))
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module AdminExtended
    module Admin
      class CommentsController < Decidim::AdminExtended::Admin::ApplicationController
        include Decidim::ApplicationHelper
        include Decidim::AdminExtended::Admin::CommentsFilterable

        helper Decidim::Projects::SharedHelper
        helper Decidim::ResourceHelper

        before_action :check_filters, only: %i[index export]

        helper_method :comments, :admin_filter_selector, :comment


        def index
          @form = form(Decidim::AdminExtended::Admin::CommentSearchForm).from_params(params)
          enforce_permission_to :update, :organization, organization: current_organization
        end

        def export
          @form = form(Decidim::AdminExtended::Admin::CommentSearchForm).from_params(params)
          @comments = filtered_collection.limit(5000)
          create_log(current_user, 'admin_comments_export')
          respond_to do |format|
            format.xlsx
          end
        end

        def hide
          enforce_permission_to :update, :organization, organization: current_organization

          Decidim::Admin::HideResource.call(comment, current_user, 'admin_hide') do
            on(:ok) do
              flash[:notice] = I18n.t('reportable.hide.success', scope: 'decidim.moderations.admin')
              redirect_to comments_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t('reportable.hide.invalid', scope: 'decidim.moderations.admin')
              redirect_to comments_path
            end
          end
        end

        private

        # Owerwritten to remove filters
        # Renders the filters selector with tags in the admin panel.
        def admin_filter_selector(i18n_ctx = nil)
          render partial: 'decidim/admin_extended/admin/comments/filters', locals: { i18n_ctx: i18n_ctx }
        end

        def comment
          @comment ||= Decidim::Comments::Comment.find_by(id: params[:id])
        end

        def base_query
          @form.find_comments
        end

        def comments
          @comments ||= filtered_collection
        end

        def check_filters
          if params[:q].present? && params[:q][:body_cont].present? && params[:q][:body_cont].size < 3
            flash[:error] = I18n.t('minimum_signs', scope: 'activemodel.attributes.comment_search')
            redirect_to comments_path
          end
        end

        def create_log(resource, log_type)
          Decidim.traceability.perform_action!(
            log_type,
            resource,
            current_user,
            visibility: 'admin-only'
          )
        end
      end
    end
  end
end

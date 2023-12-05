# frozen_string_literal: true

Decidim::ProfileCell.class_eval do
    def show
      if profile_holder.blocked? && current_user_logged_in?
        render :inaccessible
      else
        render :show_new
      end
    end
  end
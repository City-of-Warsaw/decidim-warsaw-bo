# frozen_string_literal: true

Decidim::Comments::CommentsCell.class_eval do
  include Decidim::Comments::Engine.routes.mounted_helpers
  include SecureHeaders::ViewHelpers

  def show
    render :show_new
  end

  def add_comment
    return if single_comment?
    return if comments_blocked?
    return if user_comments_blocked?

    render :add_comment_new
  end

  # overwritten method
  # change pollingInterval from default 15000 to 30000 (30 sek)
  def comments_data
    {
      singleComment: single_comment?,
      toggleTranslations: machine_translations_toggled?,
      commentableGid: model.to_signed_global_id.to_s,
      commentsUrl: decidim_comments.comments_path,
      rootDepth: root_depth,
      lastCommentId: last_comment_id,
      order: order,
      pollingInterval: 30000
    }
  end

  private

  def available_orders
    %w(recent older most_discussed)
  end
end

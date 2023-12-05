# frozen_string_literal: true

Decidim::Comments::Permissions.class_eval do
  def permissions
    return permission_action if permission_action.subject != :comment

    case permission_action.action
    when :read
      can_read_comments?
    when :create
      can_create_comment?
    when :vote
      can_vote_comment?
    when :hide
      can_hide_comment?
    end

    permission_action
  end

  private

  def can_hide_comment?
    return disallow! unless user
    return disallow! unless comment

    toggle_allow(comment.author == user)
  end
end

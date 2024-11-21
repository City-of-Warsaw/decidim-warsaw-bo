# frozen_string_literal: true

Decidim::Comments::Comment.class_eval do

  Decidim::Comments::Comment.const_set("NEW_MAX_DEPTH", 1)
  scope :search_default, -> { joins('JOIN decidim_users ON decidim_users.id = decidim_comments_comments.decidim_author_id').joins('JOIN decidim_projects_projects ON decidim_projects_projects.id = decidim_comments_comments.decidim_root_commentable_id') }

  def accepts_new_comments?
    root_commentable.accepts_new_comments? && depth < Decidim::Comments::Comment::NEW_MAX_DEPTH
  end

  def reported_at
    return unless moderation

    moderation.created_at
  end

  def report_reason
    return if reports.none?

    reports.first.reason
  end

  # Allow ransacker to search for body of comment
  ransacker :body do
    Arel.sql('LOWER("decidim_comments_comments"."body"::TEXT)')
  end

  ransacker :project_title do |parent|
    Arel.sql('LOWER("decidim_projects_projects"."title"::TEXT)')
  end

  ransacker :signature do |parent|
    Arel.sql('"decidim_users"."anonymous_number"')
  end

  ransacker :author do |parent|
    Arel.sql('LOWER("decidim_users"."last_name"::TEXT)')
  end

  ransacker :reported_at do |parent|
    Arel.sql('"decidim_moderations"."created_at"')
  end
  ransacker :is_comment_hidden do |parent|
    Arel.sql('"is_comment_hidden"')
  end
  
end

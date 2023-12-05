# frozen_string_literal: true

class OldModels::Comment
  include Virtus.model

  attribute :id, Integer
  attribute :creatorId, Integer
  attribute :createTime, String
  attribute :text, String
  attribute :parentCommentId, Integer
  attribute :deletedByUser, Boolean
  attribute :deletedByAdmin, Boolean
  attribute :deleteTime, String
  attribute :reportCount, Integer

  def build_comment(project, author)
    c = Decidim::Comments::Comment.new
    c.author = author # from creatorId
    c.old_id = id
    c.root_commentable = project
    c.created_at = createTime
    c.body = { "pl" => text_or_deleted.first(5000) }
    if parentCommentId.nil? || parentCommentId == 0
      c.commentable = project
    else
      c.commentable = Decidim::Comments::Comment.find_by(old_id: parentCommentId)
      return unless c.commentable
    end
    c
  end

  def create_comment(project, author)
    c = build_comment(project, author)
    return unless c

    c.body = { "pl" => "" }
    c.save!
    c.update_column(:body,  { "pl" => text_or_deleted.gsub("\r\n", "<br/>") }) # bypass validation for text limit
    c
  end

  def text_or_deleted
    deletedByUser ? 'Komentarz został usunięty przez autora' : text.gsub("\r\n", "<br/>")
  end
end


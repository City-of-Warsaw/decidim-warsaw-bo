# frozen_string_literal: true

Decidim::Comments::CommentThreadCell.class_eval do
  def author_name
    if model.signature.present?
      model.signature
    elsif model.author.deleted?
      t("decidim.components.comment.deleted_user")
    else
      if model.author.respond_to?(:public_name)
        if model.root_commentable.created_by?(model.author)
          "#{model.author.public_name(false)} - Autor projektu"
        elsif model.root_commentable.authored_by?(model)
          "#{model.author.public_name(false)} - Współautor projektu"
        else
          model.author.public_name(true)
        end
      else
        model.author.name
      end
    end
  end
end

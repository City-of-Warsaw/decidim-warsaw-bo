# frozen_string_literal: true

Decidim::Comments::CreateComment.class_eval do

  private

  def create_comment
    parsed = Decidim::ContentProcessor.parse(form.body, current_organization: form.current_organization)

    params = {
      author: @author,
      commentable: form.commentable,
      root_commentable: root_commentable(form.commentable),
      body: { I18n.locale => parsed.rewrite },
      alignment: form.alignment,
      decidim_user_group_id: form.user_group_id,
      # custom
      signature: @author.try(:comment_signature)
    }

    @comment = Decidim.traceability.create!(
      Decidim::Comments::Comment,
      @author,
      params,
      visibility: "public-only"
    )

    Decidim::Comments::CommentCreation.publish(@comment, parsed.metadata)
    send_email_notifications
  end

  def send_email_notifications
    project_author_mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'new_comment_project_author_info_email_template')
    commentator_mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'new_comment_interlocutor_info_email_template')
    if project_author_mail_template
      @comment.root_commentable.authors.each do |user|
        next if user == @author # we do not send emails if comment was created by one of the project authors
        next unless user.inform_me_about_comments

        Decidim::Projects::TemplatedMailerJob.perform_later(@comment, user, project_author_mail_template)
      end
    end
    if commentator_mail_template
      @comment.root_commentable.comments.map(&:author).uniq.each do |user|
        next if user == @author # we do not send emails to author of teh comment
        next if @comment.root_commentable.authors.include?(user) # we do not send THIS email to projects author
        next unless user.inform_me_about_comments

        Decidim::Projects::TemplatedMailerJob.perform_later(@comment, user, commentator_mail_template)
      end
    end
  end
end

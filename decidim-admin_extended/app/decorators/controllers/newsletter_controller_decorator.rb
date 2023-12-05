# frozen_string_literal: true

Decidim::Admin::NewslettersController.class_eval do
  def select_recipients_to_deliver
    enforce_permission_to :update, :newsletter, newsletter: newsletter
    @form = form(Decidim::Admin::SelectiveNewsletterForm).from_model(newsletter)
  end

  def deliver
    enforce_permission_to :update, :newsletter, newsletter: newsletter
    @form = form(Decidim::Admin::SelectiveNewsletterForm).from_params(params)

    Decidim::Admin::DeliverNewsletter.call(newsletter, @form, current_user) do
      on(:ok) do
        flash[:notice] = I18n.t("newsletters.deliver.success", scope: "decidim.admin")
        redirect_to action: :index
      end

      on(:invalid) do
        flash.now[:error] = I18n.t("newsletters.deliver.error", scope: "decidim.admin")
        render action: :select_recipients_to_deliver
      end

      on(:invalid_email_recipients) do
        flash.now[:error] = I18n.t("newsletters.deliver.invalid_recipients", scope: "decidim.admin")
        render action: :select_recipients_to_deliver
      end

      on(:no_recipients) do
        flash.now[:error] = I18n.t("newsletters.deliver.no_recipients", scope: "decidim.admin")
        render action: :select_recipients_to_deliver
      end
    end
  end

end

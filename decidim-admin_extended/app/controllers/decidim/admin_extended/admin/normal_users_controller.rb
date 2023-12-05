# require_dependency "decidim/admin_extended/application_controller"

module Decidim::AdminExtended
  # Controller that allows managing all Normal Users - users that do not have email addresses - at the admin panel.
  class Admin::NormalUsersController < Decidim::AdminExtended::Admin::ApplicationController

    def new
      enforce_permission_to :create, :admin_user
      @form = form(Admin::NormalUserCreateForm).instance
    end

    def create
      enforce_permission_to :create, :admin_user

      default_params = {
        organization: current_organization,
        invitation_instructions: "invite_user",
        invited_by: current_user,
        name: 'fake',
        nickname: 'fake'
      }
      @form = Admin::NormalUserCreateForm.from_params(params[:normal_user].merge(default_params))
      if Decidim::User.find_by(email: params[:normal_user][:email])
        flash[:alert] = 'Użytkownik o takim adresie e-mail już jest istnieje'
        redirect_to decidim_admin.officializations_path
      elsif @form.valid? && Decidim::CreateNormalUser.new(@form.email, current_organization, params[:normal_user].merge(default_params)).find_or_create
        user = Decidim::User.find_by(email: params[:normal_user][:email])
        if @form.confirmed
          user.update_column('confirmed_at', DateTime.current)
        else
          user.update_column('confirmed_at', nil)
          user.invite!
        end
        flash[:notice] = I18n.t("users.create.success", scope: "decidim.admin")
        redirect_to decidim_admin.officializations_path
      else
        flash.now[:alert] = I18n.t("users.create.error", scope: "decidim.admin")
        render :new
      end
    end

    def edit
      enforce_permission_to :create, :admin_user
      Decidim.traceability.perform_action! :show_email, user, current_user

      @form = form(Admin::NormalUserCreateForm).from_model(user)
    end

    def update
      enforce_permission_to :create, :admin_user

      default_params = {
        id: user.id,
        organization: current_organization,
        invitation_instructions: "invite_user",
        invited_by: current_user
      }

      @form = form(Decidim::AdminExtended::Admin::NormalUserUpdateForm).from_params(params.merge(default_params))
      @form.confirmed_at = DateTime.current if user.confirmed_at.blank? && @form.confirmed

      if @form.valid? && update_user
        Decidim.traceability.perform_action! :update_user, user, current_user

        flash[:notice] = I18n.t("users.update.success", scope: "decidim.admin")
        redirect_to decidim_admin.officializations_path
      else
        flash.now[:alert] = I18n.t("users.update.error", scope: "decidim.admin")
        @form.id = user.id
        render :edit
      end
    end

    private

    def user
      @user ||= Decidim::User.find params[:id]
    end

    def update_user
      attrs = {
        email: @form.email,
        # nickname: @form.nickname,
        first_name: @form.first_name,
        last_name: @form.last_name,
        gender: @form.gender,
        about: @form.about,
        email_on_notification: @form.email_on_notification,
        allow_private_message: @form.allow_private_message,
        inform_me_about_comments: @form.inform_me_about_comments,
        newsletter: @form.newsletter,
        watched_implementations_updates: @form.watched_implementations_updates,
        inform_about_admin_changes: @form.inform_about_admin_changes
      }
      attrs = attrs.merge(password: @form.password) if @form.password.present?
      attrs = attrs.merge(confirmed_at: @form.confirmed_at) if @form.confirmed_at.present?

      user.update(attrs)
    end
  end
end

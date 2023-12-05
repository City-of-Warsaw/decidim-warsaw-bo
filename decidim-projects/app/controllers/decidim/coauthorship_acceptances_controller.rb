# frozen_string_literal: true

module Decidim
  # This controller allows users to register after being invited as author or coauthor if email was provided.
  # It uses layout that looks similar to basic registration.
  class CoauthorshipAcceptancesController < Decidim::ApplicationController
    include FormFactory
    helper_method :resource_name

    invisible_captcha

    def edit
      @user = Decidim::User.find(params[:id])

      @form = form(Decidim::Projects::CoauthorRegistrationForm).from_model(@user)

      if @user.sign_in_count > 0
        flash[:alert] = 'Konto zostało juz aktywowane'
        redirect_to root_path
      end
    end

    def update
      @user = Decidim::User.find(params[:id])

      if @user.sign_in_count > 0
        flash[:alert] = 'Konto zostało juz aktywowane. Zaloguj się i kliknij ponownie w link z maila, by móc potwierdzić współautorstwo projektu.'
        redirect_to decidim.new_user_session_path
      else
        @form = form(Decidim::Projects::CoauthorRegistrationForm).from_params(params[:user].merge(id: params[:id], email: @user.email))

        Decidim::Projects::RegisterCoauthor.call(@user, @form) do
          on(:ok) do
            sign_in(:user, @user)
            @project = Decidim::Projects::Project.from_all_author_identities(@user)
                                                 .where('decidim_coauthorships.confirmation_status': ['waiting', 'invited'])
                                                 .last

            flash[:notice] = 'Konto zostało zarejestrowane.'

            if @project
              flash[:notice] = "#{flash[:notice]} Poniżej znajdziesz przycisk do akceptacji współautorstwa projektu."
              redirect_to Decidim::ResourceLocatorPresenter.new(@project).url
            else
              redirect_to '/'
            end
          end

          on(:invalid) do
            flash.now[:alert] = @form.errors[:base].join(", ") if @form.errors[:base].any?
            render :edit
          end
        end
      end
    end

    protected

    def resource_name
      :user
    end
  end
end

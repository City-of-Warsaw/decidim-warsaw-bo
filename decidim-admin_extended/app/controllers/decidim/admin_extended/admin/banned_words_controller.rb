# frozen_string_literal: true

module Decidim::AdminExtended
  # Controller that allows managing all Banned Words (dictionary) at the admin panel.
  class Admin::BannedWordsController < Decidim::AdminExtended::Admin::ApplicationController
    layout "decidim/admin/settings"
    helper_method :banned_words

    def index
      enforce_permission_to :update, :organization, organization: current_organization
      render 'index'
    end

    def new
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::Admin::BannedWordForm).instance
    end

    def create
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::Admin::BannedWordForm).from_params(params)

      Decidim::AdminExtended::Admin::CreateBannedWord.call(@form) do
        on(:ok) do
          flash[:notice] = I18n.t("banned_words.create.success", scope: "decidim.admin")
          redirect_to banned_words_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("banned_words.create.error", scope: "decidim.admin")
          render :new
        end
      end
    end

    def edit
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::Admin::BannedWordForm).from_model(banned_word)
    end

    def update
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::Admin::BannedWordForm).from_params(params)

      Decidim::AdminExtended::Admin::UpdateBannedWord.call(banned_word, @form) do
        on(:ok) do
          flash[:notice] = I18n.t("banned_words.update.success", scope: "decidim.admin")
          redirect_to banned_words_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("banned_words.update.error", scope: "decidim.admin")
          render :edit
        end
      end
    end

    def destroy
      enforce_permission_to :update, :organization, organization: current_organization
      banned_word.destroy!

      flash[:notice] = I18n.t("banned_words.destroy.success", scope: "decidim.admin")

      redirect_to banned_words_path
    end

    private

    def banned_word
      @banned_word ||= banned_words.find params[:id]
    end

    def banned_words
      BannedWord.sorted_by_name
    end
  end
end

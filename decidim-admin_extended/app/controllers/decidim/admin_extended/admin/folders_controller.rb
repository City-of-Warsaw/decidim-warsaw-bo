# frozen_string_literal: true
module Decidim::AdminExtended
  class Admin::FoldersController < Decidim::AdminExtended::Admin::ApplicationController
    include Decidim::ApplicationHelper

    helper_method :folder

    def new
      enforce_permission_to :update, :documents
      @form = form(Admin::FolderForm).instance
    end

    def create
      enforce_permission_to :update, :documents
      @form = form(Admin::FolderForm).from_params(params)
      Admin::CreateFolder.call(@form) do

        on(:ok) do
          flash[:notice] = I18n.t("folders.create.success", scope: "decidim.admin_extended.admin")
          redirect_to documents_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("folders.create.error", scope: "decidim.admin_extended.admin")
          render :new
        end
      end
    end

    def edit
      enforce_permission_to :update, :documents
      @form = form(Admin::FolderForm).from_model(folder)
    end

    def update
      enforce_permission_to :update, :documents
      @form = form(Admin::FolderForm).from_params(params)

      Admin::UpdateFolder.call(folder, @form) do
        on(:ok) do
          flash[:notice] = I18n.t("folders.update.success", scope: "decidim.admin_extended.admin")
          redirect_to documents_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("folders.update.error", scope: "decidim.admin_extended.admin")
          render :edit
        end
      end
    end

    def destroy
      enforce_permission_to :update, :documents
      folder.destroy!
      flash[:notice] = I18n.t("folders.destroy.success", scope: "decidim.admin_extended.admin")
      redirect_to documents_path
    end

    private
    
    def folder
      @folder ||= folders.find_by(id: params[:id])
    end
    
    def folders
      @folders ||= Folder.all
    end
  end
end

# frozen_string_literal: true
module Decidim::AdminExtended
  class Admin::DocumentsController < Decidim::AdminExtended::Admin::ApplicationController
    include Decidim::ApplicationHelper

    helper_method :document, :documents, :documents_outside_folders, :folders,

    def index
      enforce_permission_to :read, :documents
    end

    def new
      enforce_permission_to :update, :documents
      @form = form(Admin::DocumentForm).instance
    end

    def create
      enforce_permission_to :update, :documents
      @form = form(Admin::DocumentForm).from_params(params)

      Admin::CreateDocument.call(@form) do
        on(:ok) do
          flash[:notice] = I18n.t("documents.create.success", scope: "decidim.admin_extended.admin")
          redirect_to documents_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("documents.create.error", scope: "decidim.admin_extended.admin")
          render :new
        end
      end
    end

    def edit
      enforce_permission_to :update, :documents
      @form = form(Admin::DocumentForm).from_model(document)
    end

    def update
      enforce_permission_to :update, :documents
      @form = form(Admin::DocumentForm).from_params(params)
        
      Admin::UpdateDocument.call(document, @form) do
        on(:ok) do
          flash[:notice] = I18n.t("documents.update.success", scope: "decidim.admin_extended.admin")
          redirect_to documents_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("documents.update.error", scope: "decidim.admin_extended.admin")
          render :edit
        end
      end
    end

    def destroy
      enforce_permission_to :update, :documents
      document.destroy!
      flash[:notice] = I18n.t("documents.destroy.success", scope: "decidim.admin_extended.admin")
      redirect_to documents_path
    end

    private
    
    def folder
      @folder ||= Decidim::AdminExtended::Folder.find_by(id: params[:id])
    end

    def folders
      Folder.order_by_name.includes(:documents)
    end

    def base_query
      documents
    end

    def document
      @document ||= documents.find_by(id: params[:id])
    end
    
    def documents
      @documents ||= Document.for_user(current_user).with_attached_file
    end

    def documents_outside_folders
      documents.with_attached_file.where(folder: nil).latest_first
    end
  end
end

# frozen_string_literal: true
require_dependency "decidim/core_extended/application_controller"

module Decidim::CoreExtended
  class Account::NotesController < Decidim::CoreExtended::ApplicationController
    include Decidim::UserProfile
    include Decidim::FilterResource
    include Decidim::Paginable

    helper Decidim::ResourceHelper
    helper Decidim::DecidimFormHelper

    layout 'decidim/core_extended/user_profile'

    helper_method :notes, :note, :help_section

    def index; end

    def new
      @form = form(Decidim::CoreExtended::NoteForm).instance
    end

    def create
      @form = form(Decidim::CoreExtended::NoteForm).from_params(params)
      Decidim::CoreExtended::CreateNote.call(@form, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("account.notes.create.success", scope: "decidim.core_extended")
          redirect_to account_notes_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("account.notes.create.error", scope: "decidim.core_extended")
          render :new
        end
      end
    end

    def edit
      @form = form(Decidim::CoreExtended::NoteForm).from_model(note)
    end

    def update
      @form = form(Decidim::CoreExtended::NoteForm).from_params(params)

      Decidim::CoreExtended::UpdateNote.call(note, @form, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("account.notes.update.success", scope: "decidim.core_extended")
          redirect_to account_notes_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("account.notes.update.error", scope: "decidim.core_extended")
          redirect_to account_notes_path
        end
      end
    end

    def destroy
      note.destroy!
      flash[:notice] = I18n.t("account.notes.destroy.success", scope: "decidim.core_extended")
      redirect_to account_notes_path
    end

    private

    def note
      @note ||= Decidim::CoreExtended::Note.where(user_id: current_user.id).find_by(id: params[:id])
    end

    def notes
      paginate(Decidim::CoreExtended::Note.where(user_id: current_user.id)).sorted_by_title
    end

    def note_params
      params.require(:notes).permit(:title, :body)
    end

    def help_section
      @help_section ||= Decidim::ContextualHelpSection.find_content(current_organization, 'notes')
    end
  end
end

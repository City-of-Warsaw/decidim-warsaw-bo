# frozen_string_literal: true

# OVERWRITTEN DECIDIM CONTROLLER
# Controller that allows handling Admin Logs actions
Decidim::Admin::LogsController.class_eval do
  include Decidim::AdminExtended::Admin::LogsHelper

  helper_method :collection, :paginated_collection, :applied_params_hash,:all_logs

  def index
    enforce_permission_to :read, :admin_log
    @form = form(Decidim::AdminExtended::Admin::LogSearchForm).from_params(params)
    @logs = paginated_collection
  end

  # controller action for exporting logs to files
  def export
    create_log(current_user, 'admins_logs_export')
    @form = form(Decidim::AdminExtended::Admin::LogSearchForm).from_params(params)
    respond_to do |format|
      format.xlsx
    end
  end

  private

  def paginated_collection
    @paginated_collection ||= all_logs.page(params[:page]).per(50)
  end

  def all_logs
    @form.find_logs
  end

  # private method for creating logs
  # params:
  # resource - The resource model on which action was performed
  # log_type - name of action - String or Symbol
  def create_log(resource, log_type)
    Decidim.traceability.perform_action!(
      log_type,
      resource,
      current_user,
      visibility: "admin-only"
    )
  end
end

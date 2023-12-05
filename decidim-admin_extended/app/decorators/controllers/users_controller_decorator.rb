# frozen_string_literal: true

Decidim::Admin::UsersController.class_eval do
  include Decidim::Admin::Officializations::Filterable

  helper_method :only_inactive_account

  def index
    enforce_permission_to :read, :admin_user
    @users = filtered_collection
  end

  def export
    @users = users_collection
    create_log(current_user, 'admins_list_export')
    respond_to do |format|
      format.xlsx do
        response.headers['Content-Disposition'] = "attachment; filename=Lista_użytkowników_aktywnych_i_nieaktywnych_#{Date.current}.xlsx"
      end
    end
  end

  def edit
    user
    @form = Decidim::AdminExtended::Admin::AdminUserForm.from_model(@user)
  end

  def update
    user
    @form = Decidim::AdminExtended::Admin::AdminUserForm.from_params(params)

    @user.update_column('admin_comment_name', @form.admin_comment_name)
    flash[:notice] = 'Zaktualizowano nazwę wyświetlaną użytkownika wewnętrznego'
    redirect_to action: :index
  end

  def activate_ad
    user
    @user.update_column('ad_access_deactivate_date', nil)
    create_log(@user, 'activate_ad_user')
    flash[:notice] = 'Aktywowano dostęp użytkownika wewnętrznego'
    redirect_to users_path(visible: true)
  end

  def deactivate_ad
    user
    @user.update_column('ad_access_deactivate_date', Time.current)
    create_log(@user, 'deactivate_ad_user')
    flash[:notice] = 'Dektywowano dostęp użytkownika wewnętrznego'
    redirect_to users_path(visible: false)
  end

  private

  def user
    @user ||= users_collection.find(params[:id])
  end

  def collection
    @collection ||= if only_inactive_account
                      users_collection.without_ad_access
                    else
                      users_collection.with_ad_access
                    end
  end

  def only_inactive_account
    params[:visible] == 'false'
  end

  def users_collection
    if current_user.ad_admin?
      current_organization_users.with_ad_role.or(current_organization.users_with_any_role.select_access)
    elsif current_user.ad_coordinator?
      ad_prefix = current_user.ad_role.split('_koord')[0]
      current_organization_users.where('ad_role LIKE ?', "#{ad_prefix}%")
    end
  end

  def current_organization_users
    current_organization.users.select_access.with_ad_name
  end

  def search_field_predicate
    :name_or_first_name_or_last_name_or_nickname_or_email_cont
  end

  def extra_allowed_params
    :visible
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
      visibility: 'admin-only'
    )
  end
end

# frozen_string_literal: true

Decidim::ParticipatoryProcesses::Permissions.class_eval do
  def permissions
    user_can_enter_processes_space_area?
    user_can_enter_process_groups_space_area?

    return permission_action if process && !process.is_a?(Decidim::ParticipatoryProcess)

    if read_admin_dashboard_action?
      user_can_read_admin_dashboard?
      return permission_action
    end

    if permission_action.scope == :public
      public_list_processes_action?
      public_list_process_groups_action?
      public_read_process_group_action?
      public_read_process_action?
      public_report_content_action?
      return permission_action
    end

    return permission_action unless user

    if !has_manageable_processes? && !user.ad_admin?
      disallow!
      return permission_action
    end
    return permission_action unless permission_action.scope == :admin

    valid_process_group_action?

    user_can_read_process_list?
    user_can_read_current_process?
    user_can_create_process?
    user_can_publish_process?
    user_can_start_voting?

    # org admins and space admins can do everything in the admin section
    org_admin_action?

    return permission_action unless process

    moderator_action?
    collaborator_action?
    valuator_action?
    process_admin_action?

    permission_action
  end


  private

  def user_can_enter_processes_space_area?
    return unless permission_action.action == :enter &&
                  permission_action.scope == :admin &&
                  permission_action.subject == :space_area &&
                  context.fetch(:space_name, nil) == :processes

    toggle_allow(user.ad_admin? || has_manageable_processes?)
  end

  def valid_process_group_action?
    return unless permission_action.subject == :process_group

    toggle_allow(user.ad_admin?)
  end

   # Any user that can enter the space area can read the admin dashboard.
   def user_can_read_admin_dashboard?
     allow! if user.ad_admin? || has_manageable_processes?
   end

  def has_manageable_processes?(role: :any)
    return unless user
    # for letting users with ad_roles get past to their specyfic permissions
    return true if user.has_ad_role?

    participatory_processes_with_role_privileges(role).any?
  end

  # Only organization admins can create a process
  # Customization: ad_admin && ad_coordinator can create process
  def user_can_create_process?
    return unless permission_action.action == :create &&
                  permission_action.subject == :process

    toggle_allow(user.ad_admin?)
  end

  # Everyone can read the process list
  def user_can_read_process_list?
    return unless read_process_list_permission_action?

    toggle_allow(user.ad_admin? || has_manageable_processes?)
  end

  def user_can_read_current_process?
    return unless read_process_list_permission_action?
    return if permission_action.subject == :process_list

    toggle_allow(user.ad_admin? || can_manage_process?)
  end

  # Customization: ad_admin && admin can publish process
  def user_can_publish_process?
    return unless permission_action.action == :publish &&
                  permission_action.subject == :process

    toggle_allow(user.ad_admin?)
  end

  def user_can_start_voting?
    return unless permission_action.action == :start_voting &&
      permission_action.subject == :start_voting

    toggle_allow(user.ad_admin?)
  end

  def can_manage_process?(role: :any)
    return unless user

    # user.ad_admin? || user.ad_coordinator? || participatory_processes_with_role_privileges(role).include?(process)
    user.has_ad_role?
  end

  def process_admin_action?
    return if user.ad_admin?
    return unless can_manage_process?(role: :admin)
    return disallow! if permission_action.action == :create &&
                        permission_action.subject == :process
    return disallow! if permission_action.action == :publish &&
                        permission_action.subject == :process

    is_allowed = [
      :component,
      :moderation
    ].include?(permission_action.subject)
    allow! if is_allowed
  end

  def org_admin_action?
    return unless user.ad_admin?

    is_allowed = [
      :attachment,
      :attachment_collection,
      :category,
      :component,
      :component_data,
      :moderation,
      :poster_template,
      :process,
      :statistics,
      :process_step,
      :process_user_role,
      :space_private_user,
      :export_space,
      :import,
    ].include?(permission_action.subject)
    allow! if is_allowed
  end
end

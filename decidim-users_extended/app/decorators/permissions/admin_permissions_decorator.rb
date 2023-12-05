Decidim::Admin::Permissions.class_eval do
  def permissions
    return permission_action if managed_user_action?

    unless permission_action.scope == :admin
      read_admin_dashboard_action?
      return permission_action
    end

    unless user
      disallow!
      return permission_action
    end

    if read_assembly_action?
      disallow!
      return permission_action
    end

    if user_manager?
      begin
        allow! if user_manager_permissions.allowed?
      rescue Decidim::PermissionAction::PermissionNotSetError
        nil
      end
    end

    can_manage_space?(role: :any)

    components_actions?
    read_admin_dashboard_action?
    publish_components_action?
    apply_newsletter_permissions_for_admin!

    read_processes_action?
    global_moderation_action?
    read_admin_log_action?

    read_admin_users?
    allowed_to_manage_project_form?
    allowed_to_import_voters?
    allowed_to_manage_poster_template?
    allowed_to_manage_documents?

    if user.ad_admin? && admin_terms_accepted?
      allow! if read_metrics_action?
      allow! if static_page_action?
      allow! if organization_action?
      allow! if user_action?

      allow! if permission_action.subject == :category
      allow! if permission_action.subject == :endorsement_list_setting
      allow! if permission_action.subject == :component
      allow! if permission_action.subject == :statistics
      allow! if permission_action.subject == :admin_user
      allow! if permission_action.subject == :attachment
      allow! if permission_action.subject == :attachment_collection
      allow! if permission_action.subject == :scope
      allow! if permission_action.subject == :scope_type
      allow! if permission_action.subject == :area
      allow! if permission_action.subject == :area_type
      allow! if permission_action.subject == :user_group
      allow! if permission_action.subject == :officialization
      allow! if permission_action.subject == :moderate_users
      allow! if permission_action.subject == :authorization
      allow! if permission_action.subject == :authorization_workflow
      allow! if permission_action.subject == :static_page_topic
      allow! if permission_action.subject == :help_sections
      allow! if permission_action.subject == :share_token
    end
    permission_action
  end

  private

  def user_manager?
    user && !user.admin? && !user.ad_admin? && user.role?("user_manager")
  end

  def read_admin_users?
    return unless permission_action.subject == :admin_user
    return unless permission_action.action == :read

    toggle_allow(user.ad_admin? || user.ad_coordinator?)
  end

  def read_processes_action?
    return unless permission_action.subject == :space_area &&
                  permission_action.action == :enter &&
                  context.fetch(:space_name, nil) == :processes

    toggle_allow(user.has_ad_role?)
  end

  def read_assembly_action?
    return true if permission_action.subject == :space_area &&
                  permission_action.action == :enter &&
                  context.fetch(:space_name, nil) == :assemblies
  end

  def read_admin_dashboard_action?
    return unless permission_action.subject == :admin_dashboard &&
                  permission_action.action == :read

    return user_manager_permissions if user_manager?

    toggle_allow(user.has_ad_role?)
  end

  def read_admin_log_action?
    return unless permission_action.subject == :admin_log &&
                  permission_action.action == :read

    toggle_allow(user.ad_admin?)
  end

  def global_moderation_action?
    return unless permission_action.subject == :global_moderation

    toggle_allow(user.ad_admin?)
  end

  def apply_newsletter_permissions_for_admin!
    return unless admin_terms_accepted?
    return unless permission_action.subject == :newsletter
    return allow! if user.ad_admin?
    return unless user.ad_admin?
    return unless space_allows_admin_access?

    newsletter = context.fetch(:newsletter, nil)

    case permission_action.action
    when :index, :create
      allow!
    when :read, :update, :destroy
      toggle_allow(user == newsletter.author)
    end
  end

  def components_actions?
    all_ad_users_component_actions?
    ad_admins_component_actions?
  end

  def all_ad_users_component_actions?
    return unless permission_action.subject == :component &&
                  ( permission_action.action == :read
                    permission_action.action == :manage )

    toggle_allow(user.has_ad_role?)
  end

  def ad_admins_component_actions?
    return unless permission_action.subject == :component &&
                  ( permission_action.action == :create ||
                    permission_action.action == :update ||
                    permission_action.action == :delete ||
                    permission_action.action == :copy )

    toggle_allow(user.ad_admin? && admin_terms_accepted?)
  end

  def publish_components_action?
    return unless permission_action.subject == :component &&
                  permission_action.action == :publish

    toggle_allow(user.ad_admin? && admin_terms_accepted?)
  end

  # from Decidim::Admin::Permissions
  def can_manage_space?(role: :any)
    return unless user
    return unless current_participatory_space
    return unless user.has_ad_role?
    return unless (permission_action.subject == :process && permission_action.subject == :assembly)

    toggle_allow(user.ad_admin? || has_role_in_space?(role))
  end

  def has_role_in_space?(role)
    return false unless user
    return false unless current_participatory_space
    return false unless user.has_ad_role?

    if current_participatory_space.is_a?(Decidim::ParticipatoryProcess)
      participatory_processes_with_role_privileges(role).include?(current_participatory_space)
    elsif current_participatory_space.is_a?(Decidim::Assembly)
      assemblies_with_role_privileges(role).include?(current_participatory_space)
    end
  end

  def allowed_to_import_voters?
    return unless permission_action.subject == :voters_import

    toggle_allow(user.ad_admin?)
  end

  def allowed_to_manage_poster_template?
    return unless permission_action.subject == :poster_template && permission_action.action == :manage

    toggle_allow(user.ad_admin?)
  end

  # Management permissions for documents:
  # - admin can all
  # - rest ad users - permissions are saved with files
  def allowed_to_manage_documents?
    return unless permission_action.subject == :documents

    if permission_action.action == :read
      toggle_allow(user.has_ad_role?)
    else
      toggle_allow(user.ad_admin?)
    end
  end

  def allowed_to_manage_project_form?
    return unless permission_action.subject == :projects
    return unless permission_action.action == :maintain_form ||
                  permission_action.action == :read_form

    if permission_action.action == :maintain_form && current_participatory_space
      toggle_allow(user.ad_admin? && space_projects(current_participatory_space).none?)
    else
      toggle_allow(user.ad_admin?)
    end
  end

  def space_projects(space)
    Decidim::Projects::Project.joins(:component).where('decidim_components.participatory_space_id': space.id)
  end

  # Returns a collection of Participatory processes where the given user has the
  # specific role privilege.
  def participatory_processes_with_role_privileges(role)
    Decidim::ParticipatoryProcessesWithUserRole.for(user, role)
  end

  def assemblies_with_role_privileges(role)
    Decidim::Assemblies::AssembliesWithUserRole.for(user, role)
  end

  def current_participatory_space
    @current_participatory_space ||= context.fetch(:current_participatory_space, nil) || context.fetch(:process, nil) || context.fetch(:assembly, nil)
  end

  def component
    @component ||= context.fetch(:current_component, nil)
  end

  def coordinators(user, evaluated_project, scope)
    # the current project unit and if there is none, the project scope unit
    department_id = evaluated_project&.current_department_id.presence || scope&.department&.id
    user.ad_coordinator? && department_id == user.department.id
  end

  def sub_coordinator(user, evaluated_project, scope)
    # the current project unit and if there is none, the project scope unit
    department_id = evaluated_project&.current_department_id.presence || scope&.department&.id
    # only the most recently assigned sub-coordinator has additional permissions and from the current department
    user.ad_sub_coordinator? &&
      evaluated_project.sub_coordinators.last == user && department_id == user.department.id
  end

  def verificators(user, evaluated_project, scope)
    user.ad_verifier? && evaluated_project.evaluators.pluck(:id).include?(user.id)
  end

  def editor(user, evaluated_project, scope)
    # only for update
    user.ad_editor? && evaluated_project.state == 'draft' && evaluated_project.editor == user
  end

  def managed_user_action?
    return unless permission_action.subject == :managed_user
    return user_manager_permissions if user_manager?
    return unless user&.ad_admin?

    case permission_action.action
    when :create
      toggle_allow(!organization.available_authorizations.empty?)
    else
      allow!
    end

    true
  end

  def user_action?
    return unless [:user, :impersonatable_user].include?(permission_action.subject)

    subject_user = context.fetch(:user, nil)

    case permission_action.action
    when :promote
      subject_user.managed? && Decidim::ImpersonationLog.active.where(admin: user).empty?
    when :impersonate
      available_authorization_handlers? &&
        !subject_user.admin? &&
        !subject_user.ad_admin? &&
        subject_user.roles.empty? &&
        Decidim::ImpersonationLog.active.where(admin: user).empty?
    when :destroy
      subject_user != user
    else
      true
    end
  end
end

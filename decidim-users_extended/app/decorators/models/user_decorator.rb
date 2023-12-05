# frozen_string_literal: true

Decidim::User.class_eval do
  # Decidim::User::AD_ROLES = %w(admin coordinator sub_coordinator verificator editor).freeze
  Decidim::User::GENDERS = %w[male female].freeze

  has_many :project_user_assignments,
           class_name: 'Decidim::Projects::ProjectUserAssignment',
           foreign_key: :user_id,
           dependent: :destroy
  has_many :assigned_projects,
           through: :project_user_assignments,
           class_name: 'Decidim::Projects::Project',
           source: :project

  scope :with_ad_role,     -> { where.not(ad_role: nil) }
  scope :without_ad_role,  -> { where(ad_role: nil) }
  scope :with_ad_name,      -> { where.not(ad_name: nil)}
  scope :without_ad_access, -> { with_ad_name.where.not(ad_access_deactivate_date: nil) }
  scope :with_ad_access, -> { with_ad_name.where(ad_access_deactivate_date: nil) }
  scope :admins,           -> { where('ad_role LIKE ?', '%admin') }
  scope :coordinators,     -> { where('ad_role LIKE ?', '%koord') }
  scope :sub_coordinators, -> { where('ad_role LIKE ?', '%podkoord') }
  scope :verificators,     -> { where('ad_role LIKE ?', '%weryf') }
  scope :editors,          -> { where('ad_role LIKE ?', '%edytor') }
  scope :select_access,    -> {
                            select("decidim_users.*,
                            substring(ad_role, 'decidim_bo_([\\w_]*)_(admin|podkoord|koord|weryf|edytor)') as department_name,
                            reverse(SPLIT_PART(reverse(ad_role),'_',1)) AS ad_role_suffix")
  }

  # devise configuration
  def self.allow_unconfirmed_access_for
    0.days
  end

  # functions for assigning AD roles
  def ad_admin?
    ad_role&.include?('_admin')
  end

  def ad_coordinator?
    ad_role&.include?('_koord')
  end

  def ad_sub_coordinator?
    ad_role&.include?('_podkoord')
  end

  def ad_verifier?
    ad_role&.include?('_weryf')
  end

  def ad_editor?
    ad_role&.include?('_edytor')
  end

  def ad_role_name
    return unless ad_role

    begin
      ad_role.match(/decidim_bo_([\w_]*)_(admin|podkoord|koord|weryf|edytor)/)[2]
    rescue StandardError
      'nieznana rola'
    end
  end

  def role_name
    case ad_role_name
    when 'admin' then 'Administrator'
    when 'koord' then 'Koordynator'
    when 'podkoord' then 'Podkoordynator'
    when 'weryf' then 'Weryfikator'
    when 'edytor' then 'Edytor'
    else
      'nieznana rola'
    end
  end

  # verify if user is coordinator for project
  def coordinator_for?(project)
    scope = project.scope.presence || Decidim::Scope.find_by(department_id: project.current_department_id)

    # aktualna jednostka projektu a jeśli jej nie ma, to jednostka zakresu projektu
    department_id = project&.current_department_id.presence || scope&.department&.id
    ad_coordinator? && department_id == department.id
  end

  # verify if user is sub-coordinator for project
  def verifier_for?(project)
    ad_verifier? && project.evaluators.pluck(:id).include?(id)
  end

  # Public method
  #
  # Returns collection of projects, to which user is author or coauthor
  def projects
    Decidim::Projects::Project.joins(:coauthorships)
                              .where('decidim_coauthorships.decidim_author_type': 'Decidim::UserBaseEntity')
                              .where('decidim_coauthorships.decidim_author_id': id)
  end

  # Public method
  #
  # Returns collection of projects, to which user is author
  def authored_projects
    projects.where('decidim_coauthorships.coauthor': false)
  end

  # Public method
  #
  # Returns collection of projects, to which user is coauthor
  def coauthored_projects
    projects.where('decidim_coauthorships.coauthor': true)
  end

  # Public: returns Users department based on Users ad_role
  def department
    if ad_role
      ad_department_name = ad_role.match(/decidim_bo_([\w_]*)_(admin|podkoord|koord|weryf|edytor)/)[1]

      Decidim::AdminExtended::Department.find_by(ad_name: ad_department_name).presence
    end
  end

  def assigned_scope_id
    Decidim::Scope.find_by(code: department.ad_name)&.id if department
  end

  def has_ad_role?
    ad_role.present?
  end

  def public_name(with_number = false)
    if has_ad_role?
      ad_full_name
    elsif deleted?
      I18n.t('decidim.profile.deleted')
    else
      anonymous_name(with_number)
    end
  end

  def anonymous_name(with_number = false)
    an = with_number ? " #{anonymous_number}" : ''
    if gender.present?
      "#{I18n.t(gender, scope: 'decidim.users.gender', default: I18n.t('decidim.users.gender.male'))}#{an}"
    else
      "Mieszkaniec#{an}"
    end
  end

  def name_and_surname
    [first_name.presence, last_name.presence].compact.join(' ')
  end

  def ad_full_name
    "#{name_and_surname} (#{role_name})"
  end

  def address
    "#{street} #{street_number}#{flat_number.present? ? '/' : nil}#{flat_number}, #{zip_code} #{city}"
  end

  def department_name
    department&.name
  rescue StandardError
    'brak'
  end

  def comment_signature
    if has_ad_role?
      admin_comment_name.presence || ad_full_name
    else
      ''
    end
  end

  def title
    # for admin logs
    public_name(true)
  end

  def coauthorships
    Decidim::Coauthorship.where(coauthorable_type: 'Decidim::Projects::Project', decidim_author_type: 'Decidim::UserBaseEntity', decidim_author_id: id)
  end

  def author_of_projects
    coauthorships.where(coauthor: false).map(&:project)
  end

  def coauthor_of_projects
    coauthorships.where(coauthor: true).map(&:project)
  end

  ransacker :first_name do |_parent|
    Arel.sql('LOWER("decidim_users"."first_name"::TEXT)')
  end

  ransacker :last_name do |_parent|
    Arel.sql('LOWER("decidim_users"."last_name"::TEXT)')
  end

  ransacker :name do |_parent|
    Arel.sql('LOWER("decidim_users"."last_name"::TEXT)')
  end

  ransacker :ad_role_suffix do |_parent|
    Arel.sql('"ad_role_suffix"')
  end

  ransacker :department_name do |_parent|
    Arel.sql('"department_name"')
  end
end

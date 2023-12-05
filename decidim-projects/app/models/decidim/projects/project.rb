# frozen_string_literal: true

module Decidim::Projects
  # Project is the main model of this engine. It allows users to submit their projects in chosen Scope.
  # After being submitted, Projests are evaluated in two steps:
  # They are given Formal Evaluation, and if it is Positive, then they are given the Meritorical Evaluation.
  # If they are evaluated negatively, users can submit Appeals, which results in Reevaluation.
  # All of the submitted Projects can be viewed by users on public pages.
  class Project < ApplicationRecord
    include Decidim::Coauthorable
    include Decidim::HasComponent
    include Decidim::ScopableResource
    include Decidim::HasReference
    include Decidim::Reportable
    include Decidim::HasAttachments
    include Decidim::Followable
    include Decidim::Comments::Commentable
    include Decidim::Searchable

    has_paper_trail versions: { class_name: 'Decidim::Projects::ProjectVersion' },
                    meta: {
                      visible: :set_visible_or_default,
                      created_at: :createTime,
                      visible_type: :visible_type,
                      signature: :admin_signature
                    }
    include Decidim::Loggable
    include Decidim::Fingerprintable
    include Decidim::ParticipatorySpaceResourceable # for routing

    # Evaluation in progress --> after submission stage set automatically for all projects - in_evaluation
    module POSSIBLE_STATES
      DRAFT = 'draft' # kopia robocza
      PUBLISHED = 'published' # zgłoszony [3]
      WITHDRAWN = 'withdrawn' # wycofany przez autora [-2]
      EVALUATION = 'evaluation' # Trwa ocena [4]
      ACCEPTED = 'accepted' # dopuszczony do głosowania [5]
      REJECTED = 'rejected' # Oceniony negatywnie [-1]
      SELECTED = 'selected' # wybrany w głosowaniu [6]
      NOT_SELECTED = 'not_selected' # nie wybrany w głosowaniu [-3]
    end

    ADMIN_STATES_FOR_SEARCH = %w(draft admin_draft published withdrawn accepted rejected selected not_selected).freeze # project states for search in admin panel
    ADMIN_VERIFICATION_STATES_FOR_SEARCH = %w(waiting formal formal_finished formal_accepted meritorical meritorical_finished meritorical_accepted finished).freeze # project verification states for search in admin panel
    STATES_FOR_SEARCH = %w(published withdrawn accepted rejected selected not_selected).freeze # project states for search in public views
    ADMIN_POSSIBLE_STATES = %w(admin_draft published accepted rejected withdrawn selected not_selected in_progress finished).freeze # project states available in admin panel
    ADMIN_STATES_ORDER = %w(published accepted rejected selected not_selected in_progress admin_draft draft finished withdrawn).freeze # project states order for admin panel

    module VERIFICATION_STATES
      WAITING = 'waiting' # oczekuje
      FORMAL = 'formal' # in formal evaluation
      FORMAL_FINISHED = 'formal_finished' # formal evaluation forwarded to coordinator
      FORMAL_ACCEPTED = 'formal_accepted' # formal evaluation accepted
      MERITORICAL = 'meritorical' # in meritorical evaluation
      MERITORICAL_FINISHED = 'meritorical_finished' # meritorical evaluation forwarded to coordinator
      MERITORICAL_ACCEPTED = 'meritorical_accepted' # meritorical evaluation accepted
      FINISHED = 'finished' # evaluation finished
    end

    module REEVALUATION_STATES
      APPEAL_DRAFT = 'appeal_draft' # project has appeal draft
      APPEAL_WAITING_ACCEPTANCE = 'appeal_waiting_acceptance' # after send appeal to coordinator for accept
      APPEAL_WAITING = 'appeal_waiting' # appeal was submitted by user, or accepted by coordinator, waits fot new verifier
      APPEAL_VERIFICATION = 'appeal_verification' # appeal verification -> project is in reevaluation
      APPEAL_VERIFICATION_FINISHED = 'appeal_verification_finished' # reevaluation was finished by the department and can be forwarded to admins
      APPEAL_COORDINATOR_FINISHED = 'appeal_coordinator_finished' # reevaluation was accepted by coordinator
      APPEAL_ADMIN_VERIFICATION = 'appeal_admin_verification' # reevaluation is now being finished by the admins
      REEVALUATION_FINISHED = 'reevaluation_finished' # reevaluation finished
    end

    REEVALUATION_STATES_INLINE = %w(appeal_draft appeal_waiting_acceptance appeal_waiting appeal_verification appeal_verification_finished appeal_coordinator_finished appeal_admin_verification reevaluation_finished).freeze
    # appeal_draft - only for editors
    # appeal_waiting_acceptance - after send appeal to coordinator for accept
    # appeal_waiting - paper version is finished(accepted) and awaits for coordinators action or submitted by user
    # appeal_verification - evaluator is assigned
    # appeal_verification_finished - evaluator finished reevaluation and appeal awaits for coordinators action
    # appeal_admin_verification - coordinator approved reevaluation and appeal awaits for CKS action
    # reevaluation_finished - CKS has finished reevaluation

    GLOBAL_SCOPE_ID = Decidim::Scope.find_by(code: 'om')&.id

    enum conflict_status: { not_set: 0, waiting: 1, with_conflicts: 2, no_conflicts: 3 }, _prefix: true

    belongs_to :current_department,
               class_name: "Decidim::AdminExtended::Department",
               foreign_key: :current_department_id,
               optional: true
    belongs_to :current_sub_coordinator,
               class_name: "Decidim::User",
               foreign_key: :current_sub_coordinator_id,
               optional: true
    belongs_to :evaluator,
               class_name: "Decidim::User",
               foreign_key: :evaluator_id,
               optional: true
    belongs_to :region,
               class_name: "Decidim::Projects::Region",
               foreign_key: :region_id,
               optional: true
    belongs_to :notification_about_evaluation_results_send_by,
               class_name: "Decidim::UserBaseEntity",
               foreign_key: :notification_about_evaluation_results_send_by_id,
               optional: true
    has_many :project_areas,
             class_name: "Decidim::Projects::ProjectArea",
             foreign_key: :decidim_projects_project_id,
             dependent: :destroy,
             inverse_of: :project
    has_many :categories,
             through: :project_areas,
             class_name: "Decidim::Area",
             source: :area
    has_many :project_recipients,
             class_name: "Decidim::Projects::ProjectRecipient",
             foreign_key: :decidim_projects_project_id,
             dependent: :destroy,
             inverse_of: :project
    has_many :recipients,
             through: :project_recipients,
             class_name: "Decidim::AdminExtended::Recipient",
             source: :recipient
    has_many :project_votes,
             class_name: "Decidim::Projects::ProjectVote",
             foreign_key: :decidim_projects_project_id,
             dependent: :destroy,
             inverse_of: :project
    has_many :vote_cards,
             through: :project_votes,
             class_name: "Decidim::Projects::VoteCard",
             source: :vote_card
    has_many :user_assignments,
             class_name: "Decidim::Projects::ProjectUserAssignment",
             foreign_key: :project_id,
             dependent: :destroy
    has_many :users,
             through: :user_assignments,
             class_name: "Decidim::User",
             source: :user
    has_many :department_assignments,
             class_name: "Decidim::Projects::ProjectDepartmentAssignment",
             foreign_key: :project_id,
             dependent: :destroy
    has_many :departments,
             through: :department_assignments,
             class_name: "Decidim::AdminExtended::Department",
             source: :department
    has_many :implementations,
             class_name: "Decidim::Projects::Implementation",
             foreign_key: :project_id,
             dependent: :destroy

    has_many :project_conflicts,
             class_name: "Decidim::Projects::ProjectConflict",
             foreign_key: :project_id,
             dependent: :destroy
    has_many :projects_in_conflict,
             through: :project_conflicts,
             class_name: "Decidim::Projects::Project",
             source: :second_project

    has_one :formal_evaluation,
            class_name: "Decidim::Projects::FormalEvaluation",
            dependent: :destroy
    has_one :meritorical_evaluation,
            class_name: "Decidim::Projects::MeritoricalEvaluation",
            dependent: :destroy
    has_one :reevaluation,
            class_name: "Decidim::Projects::ReevaluationEvaluation",
            dependent: :destroy
    has_one :appeal,
            class_name: "Decidim::Projects::Appeal",
            dependent: :destroy
    has_one :project_rank,
            class_name: "Decidim::Projects::ProjectRank",
            dependent: :destroy

    # Attachments
    has_many :internal_documents, # wewnetrzne zalaczniki
             class_name: "Decidim::Projects::InternalDocument",
             dependent: :destroy,
             inverse_of: :attached_to,
             foreign_key: :attached_to_id
    has_many :endorsements, # listy poparcie
             class_name: "Decidim::Projects::Endorsement",
             dependent: :destroy,
             inverse_of: :attached_to,
             foreign_key: :attached_to_id
    has_many :consents, # zgody
             class_name: "Decidim::Projects::Consent",
             dependent: :destroy,
             inverse_of: :attached_to,
             foreign_key: :attached_to_id
    has_many :files, # zalaczniki
             class_name: "Decidim::Projects::VariousFile",
             dependent: :destroy,
             inverse_of: :attached_to,
             foreign_key: :attached_to_id
    has_many :implementation_photos, # zalaczniki dla realizacji, w ActiveStorage
             class_name: "Decidim::Projects::ImplementationPhoto",
             dependent: :destroy
    has_many :old_implementation_photos, # zalaczniki dla realizacji do migracji na TEST
             class_name: "Decidim::Projects::ImplementationPhotoOld",
             dependent: :destroy,
             inverse_of: :attached_to,
             foreign_key: :attached_to_id

    fingerprint fields: [:title, :body]

    component_manifest_name "projects"

    scope :accepted, -> { where(state: "accepted") }
    scope :rejected, -> { where(state: "rejected") }
    scope :withdrawn, -> { where(state: "withdrawn") }
    scope :except_rejected, -> { where.not(state: "rejected") }
    scope :except_withdrawn, -> { where.not(state: "withdrawn") }
    scope :drafts, -> { where(published_at: nil) }
    scope :except_drafts, -> { where.not(published_at: nil) }
    scope :published, -> { where.not(published_at: nil, state: ['draft', 'admin_draft']) }
    scope :for_admin, -> { where.not('decidim_projects_projects.state': 'draft') }
    scope :esog_sorted, -> { order('edition_year desc, esog_number asc NULLS last') }
    scope :order_by_most_recent, -> { order(created_at: :desc) }
    scope :waiting_for_appeal, -> { rejected.where.not(id: Decidim::Projects::Appeal.all.pluck(:project_id)) }
    scope :implementations, -> { published.where(state: POSSIBLE_STATES::SELECTED) }
    scope :implementation_on_main_site, -> { implementations.where(implementation_on_main_site: true) }
    scope :implementation_on_main_site_slider, -> { implementations.where(implementation_on_main_site_slider: true) }
    scope :results, -> { where(chosen_for_voting: true) }
    # voting
    scope :chosen_for_voting, -> { where(chosen_for_voting: true).where.not(votes_count: nil) }
    scope :on_ranking_list, -> { joins(:project_rank).where('decidim_projects_project_ranks.status': 'on_the_list') }
    # in global scope or district scope
    scope :in_global_scope, -> { where(decidim_scope_id: GLOBAL_SCOPE_ID) }
    scope :in_district_scope, -> { where.not(decidim_scope_id: GLOBAL_SCOPE_ID) }
    # for bulk actions
    scope :awaits_acceptance, -> { where.not(admin_changes: nil) }
    scope :awaits_evaluation_acceptance, -> { where(verification_status: ['formal_finished', 'meritorical_finished', 'reevaluation_finished']) }
    scope :in_evaluation, -> { where(state: [POSSIBLE_STATES::PUBLISHED, POSSIBLE_STATES::EVALUATION]) }

    searchable_fields({
                        scope_id: :decidim_scope_id,
                        participatory_space: { component: :participatory_space },
                        D: :body,
                        A: :title,
                        datetime: :published_at
                      },
                      index_on_create: ->(project) { project.official? },
                      index_on_update: ->(project) { project.published? })


    delegate :organization, :participatory_space, to: :component
    delegate :active_step, to: :participatory_space
    delegate :email_on_notification, to: :creator_author
    delegate :project_editing_end_date, :withdrawn_end_date, :time_for_voting?, :time_for_posters?,
             :evaluation_start_date, :evaluation_end_date,
             :evaluation_cards_submit_end_date, :evaluation_publish_date,
             :appeal_start_date, :appeal_end_date, :reevaluation_cards_submit_end_date, :reevaluation_end_date,
             :reevaluation_publish_date, :paper_project_submit_end_date,
             :paper_voting_submit_end_date, :status_change_notifications_sending_end_date, to: :participatory_space

    store_accessor :author_data, :first_name, :last_name, :gender, :phone_number,
                   :email, :street, :street_number, :flat_number, :zip_code, :city,
                   :show_author_name, :inform_author_about_implementations

    %w[coauthor1 coauthor2].each do |store|
      store_attribute = "#{store}_data"
      %w[first_name last_name gender phone_number
        email street street_number flat_number zip_code city
        show_author_name inform_author_about_implementations].each do |key|
        define_method("#{store}_#{key}=") do |value|
          write_store_attribute(store_attribute, key, value)
        end

        define_method("#{store}_#{key}") do
          read_store_attribute(store_attribute, key)
        end
      end
    end

    before_validation :update_recipient_names
    before_validation :update_category_names
    before_validation :update_attachment_names

    attr_accessor :visible_type
    attr_accessor :createTime
    attr_accessor :tmp_visible
    attr_accessor :admin_signature
    attr_accessor :attachment_context_for_import # setup for import all files only

    # Public: set visible version
    def set_visible_version
      self.tmp_visible = true
    end

    # Public: set visible version or default
    def set_visible_or_default
      if tmp_visible.nil? || tmp_visible == false
        self.tmp_visible = nil
        false
      else
        self.tmp_visible = nil
        true
      end
    end

    # User by decidim. The context of the attachments defines which file upload settings
    # constraints should be used when the file is uploaded. The different
    # contexts can limit for instance which file types the user is allowed to
    # upload.
    # : migration is special type to allow all content_types
    #
    # Returns Symbol.
    def attachment_context
      if attachment_context_for_import && attachment_context_for_import.in?([:admin, :migration])
        attachment_context_for_import
      else
        :participant
      end
    end

    def chosen_for_implementation?
      state == POSSIBLE_STATES::SELECTED
    end

    # Public: checking if project is in implementation
    #
    # returns Boolean
    def in_implementation?
      implementations.visible.any? || producer_list.present?
    end

    def edition
      participatory_space
    end

    # Public method that retrieves all the projects from the same component
    # that are in close location with it
    #
    # Returns ActiveRecord query of Projects
    def projects_in_potential_conflict
      Decidim::Projects::PotentiallyMutuallyExclusiveProjects.new(self).query.order(decidim_scope_id: :asc, voting_number: :asc)
    end

    # Public method changing status to 'selected'
    def selected!
      update_column('state', 'selected')
    end

    # Public method checking if status is 'selected'
    def selected?
      state == 'selected'
    end

    # Public method changing status to 'not_selected'
    def not_selected!
      update_column('state', 'not_selected')
    end

    # Public method checking if status is 'not_selected'
    def not_selected?
      state == 'not_selected'
    end

    # Public method checks if project is from global scope
    #
    # Returns Boolean
    def is_global_project?
      decidim_scope_id == GLOBAL_SCOPE_ID
    end

    # Public method checks if project is from district scope
    #
    # Returns Boolean
    def is_district_project?
      decidim_scope_id.present? && decidim_scope_id != GLOBAL_SCOPE_ID
    end

    # Public method checking if universal design is set as true
    # Attribute can also be set as nil
    #
    # returns Boolean
    def universal_design_set_true?
      universal_design == true
    end

    # Public method checking if universal design is set as false
    # Attribute can also be set as nil
    #
    # returns Boolean
    def universal_design_set_false?
      universal_design == false
    end

    # Public: saves recipients names
    #
    # Method saves recipient names as String for versioning purposes
    def update_recipient_names
      self.recipient_names = recipients.any? ? recipients.map(&:id).sort.join(',') : nil
    end

    # Public: saves attachments names
    #
    # Method saves attachment names as String for versioning purposes
    def update_attachment_names
      self.public_attachment_names = files.any? ? files.map{ |e| e.id }.sort.join(',') : nil
      self.all_attachment_names = attachments.any? ? files.map{ |e| e.id }.sort.join(',') : nil
    end

    # Public: saves categories names
    #
    # Method saves categories (Area) names as String for versioning purposes
    def update_category_names
      self.category_names = categories.any? ? categories.map{ |e| e.id }.sort.join(',') : nil
    end

    # ustawia signature podczas aktualizacji projektu przez admina
    def set_admin_signature(user)
      self.admin_signature = user.admin_comment_name
    end

    # Public: public documents
    #
    # Returns files that are documents
    def public_documents
      files.select(&:document?)
    end

    # Public: public photos
    #
    # Returns files that are images
    def public_photos
      files.select(&:photo?)
    end

    # Public method determinig if there are any public documents for display
    #
    # Returns Boolean
    def has_any_public_documents?
      public_documents.any? ||
        public_photos.any? ||
        can_show_evaluation? && !!(formal_evaluation&.documents&.any? || meritorical_evaluation&.documents&.any? || reevaluation&.documents&.any?)
    end

    # ordering

    # Public: value of admin state
    #
    # returns Integer
    def state_sort_value
      ADMIN_STATES_ORDER.find_index(state) || ADMIN_STATES_ORDER.size
    end

    # Public: projects sorted for admin view
    #
    # Method returns collection of projects sorted via order from state_sort_value method
    def self.admin_sorted(projects)
      projects.sort{|a, b| a.state_sort_value <=> b.state_sort_value }
    end

    # ordering END

    # Public: project's editor
    #
    # For projects added in admin panel (paper projects) returns
    # user that first created the project
    #
    # returns User
    def editor
      return nil unless is_paper?

      users.first
    end

    # Public: project's evaluators
    #
    # returns collection of users that were assigned to the project
    def evaluators
      users
    end

    # Public: project's sub_coordinators
    #
    # returns collection of users that were assigned to the project and have sub_coordinator role
    def sub_coordinators
      users.sub_coordinators
    end

    # Public: project's coauthors
    #
    # returns collection of coauthors
    def coauthors
      coauthorships.where(coauthor: true).order(created_at: :asc).map(&:author)
    end

    # Public: project's coauthors who confirmed coauthorship
    #
    # returns collection of coauthors
    def confirmed_coauthors
      coauthorships.where(coauthor: true).order(created_at: :asc).where(confirmation_status: 'confirmed').map(&:author)
    end

    # Public: project's coauthor
    #
    # returns object - User - first coauthor
    def coauthor_one
      coauthors[0]
    end

    # Public: project's coauthor
    #
    # returns object - User - second coauthor
    def coauthor_two
      coauthors[1]
    end

    # Public method. Returns coauthorship of first coauthor
    def coauthorship_one
      coauthorships.order(created_at: :asc).where(coauthor: true).first
    end

    # Public method. Returns coauthorship of second coauthor
    def coauthorship_two
      coauthorships.order(created_at: :asc).where(coauthor: true).second
    end

    # Public: project's previous
    #
    # returns object - Department that project was assigned to previously
    def previous_department
      return if departments.count < 2

      department_assignments.order(created_at: :desc).second.department
    end

    # Public: checking if project is in evaluation process
    #
    # returns Boolean
    def in_evaluation?
      [POSSIBLE_STATES::PUBLISHED, POSSIBLE_STATES::EVALUATION].include?(state)
    end

    def in_first_evaluation?
      in_evaluation? && within_evaluation_time?
    end

    # Public: checking if project has formal evaluation
    #
    # returns Boolean
    def has_formal_evaluation?
      formal_evaluation
    end

    # Public: checking if project has meritorical evaluation
    #
    # returns Boolean
    def has_meritorical_evaluation?
      meritorical_evaluation
    end

    # Public: project's reevaluator
    #
    # Method returns User that is assigned as evaluator when project is in reevaluation
    def reevaluator
      if is_in_reevaluation? && evaluator
        evaluator
      end
    end

    # Public: address of the project's author
    #
    # returns String
    def user_address
      creator_author.address
    end

    # Public: project's scope type
    #
    # returns object - ScopeTYpe
    def scope_type
      scope&.scope_type
    end

    # Public: generate esog numer for project
    #
    # Method finds maximum number for given participatory space and returns next number
    #
    # returns Integer
    def self.generate_esog(participatory_space)
      component = participatory_space.components.where(manifest_name: 'projects').first.id
      return 1 if where(component: component).where.not(esog_number: nil).none?

      where(component: component).published.maximum(:esog_number) + 1
    end

    # Public method
    #
    # Method defines Admin Log Presenter class
    def self.log_presenter_class_for(_log)
      Decidim::Projects::AdminLog::ProjectPresenter
    end

    # Public: list of the addresses of given locations
    #
    # Returns Array
    def list_locations
      locations.map do |l|
        l[1]['display_name']
      end
    end

    # Returns a collection scoped by an author.
    # Overrides this method in DataPortability to support Coauthorable.
    def self.user_collection(author)
      return unless author.is_a?(Decidim::User)

      joins(:coauthorships)
        .where(decidim_coauthorships: { coauthorable_type: name })
        .where("decidim_coauthorships.decidim_author_id = ? AND decidim_coauthorships.decidim_author_type = ? ", author.id, author.class.base_class.name)
    end

    # Public: collection of Projects for newsletter for given component
    #
    # Returns Project's collection
    def self.retrieve_projects_for(component)
      Decidim::Projects::Project.where(component: component).joins(:coauthorships)
                                  .includes(:vote_cards, :endorsements)
                                  .where(decidim_coauthorships: { decidim_author_type: "Decidim::UserBaseEntity" })
                                  .not_hidden
                                  .published
                                  .except_withdrawn
    end

    # Public: List of Users for newsletter, for given component
    #
    # Returns Users' collection
    def self.newsletter_participant_ids(component)
      projects = retrieve_projects_for(component).uniq

      coauthors_recipients_ids = projects.map { |p| p.notifiable_identities.pluck(:id) }.flatten.compact.uniq

      commentators_ids = Decidim::Comments::Comment.user_commentators_ids_in(projects)

      (coauthors_recipients_ids + commentators_ids).flatten.compact.uniq
    end

    # Public: custom label for project attribute
    #
    # Method retrieves label defined in admin panel in project form
    # if participatory space has project customization instance
    #
    # returns String
    def custom_label(key)
      return '' unless participatory_space.project_customization

      participatory_space.project_customization.get_additional_label(key)
    end

    # Public: Checks if the project has been published or not.
    #
    # Returns Boolean.
    def published?
      published_at.present?
    end

    # Public: Checks if the author has published the project for edition
    #
    # Returns Boolean
    def published_state?
      state == "published"
    end

    # Public: Checks if the author has withdrawn the project.
    #
    # Returns Boolean.
    def withdrawn?
      # internal_state == "withdrawn"
      state == "withdrawn"
    end

    # Public: Checks if project was accepted and acceptation of it was revealed.
    # - Returns nil if state indicates there was no evaluation made yet
    # - Returns nil if there is no formal evaluation added and it is not old project (some old projects may not have formal evaluation)
    # - Returns nil if results shouldn't yet be shown cause it is not yet reveal time
    # - Returns true if state indicates that project is after voting
    # - Returns true OR false based on the (re)evaluation if it is past reevaluation reveal time
    # - Returns true OR false based on the evaluation if it is past evaluation reveal time
    #
    # Returns Boolean OR nil.
    def accepted?
      return if %w(draft admin_draft published withdrawn evaluation).include?(state) # not yet evaluated
      return true if %w(selected not_selected).include?(state) # if it got that far it means it was accepted
      return if !formal_evaluation && !old_id

      # state == "accepted"
      if can_show_reevaluation?
        # we are past reevaluation reveal
        reevaluation ? final_result : evaluation_result
      elsif can_show_evaluation?
        # we are past evaluation reveal
        evaluation_result
      else
        # we are before evaluation reveal
      end
    end

    # Public: Checks if project was rejected and rejection of it was revealed.
    # - Returns nil if state indicates there was no evaluation made yet
    # - Returns nil if method accepted? returns nil
    # - Returns false if state indicates that project is after voting
    # - Returns true OR false based on the opposition of accepted? method
    #
    # Returns Boolean OR nil.
    def rejected?
      return if %w(draft admin_draft published withdrawn evaluation).include?(state) # not yet evaluated
      return false if %w(selected not_selected).include?(state) # if it got that far it means it was accepted
      return if accepted? == nil

      !accepted?
    end

    # Public method that determines if section with project_implementation_effects or negative_verification_reason
    # should be shown.
    # It is dependent both on state and date
    def can_we_show_verification_text_reason?
      return false if project_implementation_effects.blank? && negative_verification_reason.blank? # no value to show
      return false if %w(draft admin_draft published withdrawn evaluation).include?(state) # not yet evaluated

      # for state == accepted OR state == rejected we check if it is time to show results of evaluation
      # accepted? method takes into account the selected AND not_selected states
      (accepted? && project_implementation_effects.present?) || (rejected? && negative_verification_reason.present?)
    end

    # Public: evaluation result
    #
    # returns Boolean
    def evaluation_result
      formal_evaluation.positive_result? && meritorical_evaluation&.positive_result?
    end

    # Public: reevaluation result
    #
    # returns Boolean
    def final_result
      return unless reevaluation

      reevaluation.positive_result?
    end

    # Public: return reevaluation result even if reevaluation was not finished
    #
    # returns String
    def actual_reevaluation_result
      if reevaluation_result.nil?
        return '' unless reevaluation
        return '' if reevaluation.result.nil?

        reevaluation.positive_result? ? 'Pozytywny' : 'Negatywny'
      else
        reevaluation_result ? 'Pozytywny' : 'Negatywny'
      end
    end

    # Public: negative evaluation reason
    #
    # returns String
    def negative_evaluation_body
      return '' if accepted?

      if formal_result == false
        formal_evaluation.negative_reasons_for_xls
      elsif meritorical_result == false
        meritorical_evaluation.details['result_description']
      elsif reevaluation_result == false
        reevaluation.details['negative_reevaluation_body']
      else
        ''
      end
    end

    # Public: project implementation effects
    #
    # returns String
    def project_implementation_effects
      return if accepted? == nil

      if can_show_reevaluation?
        return super if old_id.present? # dla projektow zaimportowanych

        reevaluation&.project_implementation_effects.presence || meritorical_evaluation&.project_implementation_effects.presence || super
      elsif can_show_evaluation?
        return super if old_id.present? # dla projektow zaimportowanych

        meritorical_evaluation&.project_implementation_effects.presence || super
      else
        super
      end
    end

    # Public: negative evaluation reason
    #
    # Method returns proper reason based on the defined times of publishing them in public scope
    #
    # returns String
    def negative_verification_reason
      return if accepted? == nil

      if can_show_reevaluation?
        return super if old_id.present? # dla projektow zaimportowanych

        reevaluation&.negative_verification_reason.presence || meritorical_evaluation&.negative_verification_reason.presence || formal_evaluation.negative_verification_reason.presence || super
      elsif can_show_evaluation?
        return super if old_id.present? # dla projektow zaimportowanych

        meritorical_evaluation&.negative_verification_reason.presence || formal_evaluation.negative_verification_reason.presence || super
      else
        super
      end
    end

    # Public: checking if project is a draft added in admin panel
    #
    # returns Boolean
    def admin_draft?
      state == 'admin_draft'
    end

    # Public: checking if project was imported from previous system
    #
    # returns Boolean
    def imported?
      verification_status && verification_status == 'imported'
    end

    # Public: checking if project has any data that considers location
    #
    # returns Boolean
    def any_localization_info?
      (scope && scope.scope_type && scope.code != 'om') || address.present? || localization_info.present? || localization_additional_info.present? || local_area.present?
    end

    # Public: region name
    #
    # Among imported projects, some had additional scope data, that was mapped into Region model.
    # Method retrieves this historical data if it's present.
    #
    # returns String
    def local_area
      region&.name
    end

    # Public: checking if project exceeds limit for chosen scope
    #
    # returns Boolean
    def exceeds_limit?
      return false unless scope
      return false unless budget_value

      budget_value > participatory_space.limit_for_scope(scope)
    end

    # Public: checking how much does the budget value of project exceeds limit for chosen scope
    #
    # returns Integer
    def limit_exceeded_value
      return false unless scope
      return false unless budget_value

      budget_value - participatory_space.limit_for_scope(scope)
    end

    # Public: Overrides the `reported_content_url` Reportable concern method.
    def reported_content_url
      ResourceLocatorPresenter.new(self).url
    end

    # Public: Overrides the `reported_attributes` Reportable concern method.
    def reported_attributes
      [:title, :body]
    end

    # Public: Overrides the `reported_searchable_content_extras` Reportable concern method.
    def reported_searchable_content_extras
      [authors.map(&:name).join("\n")]
    end

    # Public: Whether the project is official or not.
    def official?
      authors.first.is_a?(Decidim::Organization)
    end

    # Public: checking if project is in reevaluation
    #
    # returns Boolean
    def is_in_reevaluation?
      return unless verification_status
      return if verification_status == 'appeal_draft'
      return if verification_status == 'reevaluation_finished'

      Decidim::Projects::Project::REEVALUATION_STATES_INLINE.include? verification_status
    end

    # Public: Checks whether the user can edit the given project.
    #
    # user - the user to check for authorship
    def editable_by?(user)
      return false unless user
      return false unless created_by?(user)
      return false if withdrawn?
      return true if draft?

      user && within_edit_time? && %(draft published).include?(state)
    end

    # Public: checking if user can public the given project.
    #
    # user - the user to check for authorship
    def publicable_by?(user)
      return false if withdrawn?
      return false unless draft?

      user && within_publication_time? && created_by?(user)
    end

    # Public: checking if user can duplicate project - if user is weather author or coauthor
    #   user - Decidim::User
    #
    # returns Boolean
    def duplicable_by?(user)
      return false if implementation_status == 0
      return false unless user

      if draft?
        # only author can duplicate draft
        user == creator_author
      else
        # author or coauthor if he confirmed coauthorship
        user == creator_author ||
          user == coauthor_one && coauthorship_one.confirmation_status == 'confirmed' ||
          user == coauthor_two && coauthorship_two.confirmation_status == 'confirmed'
      end
    end

    # Public: checking if user can destroy project
    #   user - Decidim::User
    #
    # returns Boolean
    def deletable_by?(user)
      return false unless draft?
      return false unless user

      user == creator_author
    end

    # Public: checking if user can get PDF version of the proejct
    #   user - Decidim::User
    #
    # returns Boolean
    def pdf_viewable_by?(user)
      return false if withdrawn?
      return false if implementation_status == 0

      if draft?
        # only author can see PDF of a draft
        user == creator_author
      else
        user == creator_author ||
          user == coauthor_one && coauthorship_one.confirmation_status == 'confirmed' ||
          user == coauthor_two && coauthorship_two.confirmation_status == 'confirmed'
      end
    end

    # Public: Checks whether the user can withdraw the given project.
    # Projhect can be withdrawn only by creator author:
    # - when it was published,
    # - when it is being evaluated (state == 'evaluation'),
    # - when it was evaluated (state == 'accepted' || state == 'rejected' )
    #
    # user - the user to check for withdrawability.
    def withdrawable_by?(user)
      return false if draft?
      return false if withdrawn?

      user && within_withdrawn_time? && created_by?(user) && %w(published evaluation accepted rejected).include?(state)
    end

    # Public: Checks whether the user can add appeal to the given project.
    #
    # user - the user to check for appealability.
    def appealable_by?(user)
      return false if accepted? || state != 'rejected'
      return false if appeal && appeal.submitted?

      user && within_appeal_time? && created_by?(user)
    end

    # Public: Checks whether the user can add accept invitation for coauthorship
    #
    # user - the user to check for acceptablity.
    def coauthorship_acceptable_by?(user)
      return false if coauthorships.none?
      return false unless coauthorship_waiting_for_confirmation_for(user)

      coauthorship_waiting_for_confirmation_for(user).in_acceptance_time?
    end

    # Public: Checks whether there is an active invitation to coauthorship
    # for the user
    #
    # Returns Coauthorship
    def coauthorship_waiting_for_confirmation_for(user)
      coauthorships.for_acceptance.find_by(decidim_author_id: user.id)
    end

    # Public: Returns count of confirmed authorships that are users
    def confirmed_authors_count
      return 0 if coauthorships.none?

      coauthorships.for_all_users.confirmed.count
    end

    # Public: Whether the project is a user draft or not.
    #
    # returns: Boolean
    def draft?
      published_at.nil? && state == 'draft'
    end

    # Public: Whether the project is a draft of any kind or not.
    #
    # returns: Boolean
    def any_draft?
      published_at.nil? && (state == 'draft' || state == 'admin_draft')
    end

    # Public: Defines the base query so that ransack can actually sort by this value
    def self.sort_by_valuation_assignments_count_nulls_last_query
      <<-SQL.squish
      (
        SELECT COUNT(decidim_projects_valuation_assignments.id)
        FROM decidim_projects_valuation_assignments
        WHERE decidim_projects_valuation_assignments.decidim_project_id = decidim_projects_projects.id
        GROUP BY decidim_projects_valuation_assignments.decidim_project_id
      )
      SQL
    end

    # Ransacker method for filtering via area
    ransacker :area_ids_has do
      Arel.sql("
            SELECT * FROM decidim_amendments
            WHERE decidim_amendments.decidim_emendation_type = 'Decidim::Proposals::Proposal'
            AND decidim_amendments.decidim_emendation_id = decidim_proposals_proposals.id
          ) THEN 0
          WHEN state_published_at IS NULL AND answered_at IS NOT NULL THEN 2
          WHEN state_published_at IS NOT NULL THEN 1
          ELSE 0 END
        ")
      query = <<-SQL.squish
      (
        (SELECT decidim_projects_project_areas.decidim_area_id
        FROM decidim_projects_project_areas
        WHERE decidim_projects_project_areas.decidim_project_id = decidim_projects_projects.id
        )
      )
      SQL
      where(query)
    end

    # Ransacker method for filtering via id
    ransacker :id_string do
      Arel.sql(%{cast("decidim_projects_projects"."id" as text)})
    end

    # Ransacker method for filtering via esog number
    ransacker :esog_number_string do
      Arel.sql(%{cast("decidim_projects_projects"."esog_number" as text)})
    end

    # Ransacker method for filtering only with photos
    ransacker :implementation_photos_exists do |parent|
      # returns boolean true or false
      Arel.sql("(SELECT EXISTS (SELECT 1 FROM decidim_projects_implementation_photos
                                        WHERE decidim_projects_implementation_photos.project_id = decidim_projects_projects.id))")
    end

    # Public: defines class for Serializing projects data
    def self.export_serializer
      Decidim::Projects::ProjectSerializer
    end

    def self.data_portability_images(user)
      user_collection(user).map { |p| p.attachments.collect(&:file) }
    end

    # Public: Checks whether the project is inside the time window to be editable or not once published.
    #
    # returns Boolean
    def within_edit_time?
      return unless project_editing_end_date
      return true if draft?

      Date.current <= project_editing_end_date
    end

    # Public: Checks whether the project is inside the time window to be published.
    #
    # returns Boolean
    def within_publication_time?
      return unless active_step
      return unless active_step.start_date
      return unless active_step.end_date

      active_step.start_date <= Date.current && Date.current <= active_step.end_date &&
      (active_step.system_name == 'submitting' || component.step_settings[active_step.id.to_s].creation_enabled)
    end

    # Public: Checks whether the project is inside the time window to be submitted.
    #
    # returns Boolean
    def within_paper_submit_time?
      return unless paper_project_submit_end_date

      Date.current <= paper_project_submit_end_date
    end

    # Public: Checks whether the project is inside the time window to be withdrawn.
    #
    # returns Boolean
    def within_withdrawn_time?
      return unless withdrawn_end_date

      Date.current <= withdrawn_end_date
    end

    # Public: Checks whether the project is inside the time window to be evaluated
    #
    # returns Boolean
    def within_evaluation_time?
      return unless evaluation_end_date
      return unless evaluation_start_date

      evaluation_start_date <= DateTime.current  && DateTime.current <= evaluation_end_date
    end

    # Public: Checks whether the project is inside the time window to be evaluated by verifiers
    #
    # returns Boolean
    def withing_verificators_evaluation_time?
      return unless evaluation_cards_submit_end_date

      DateTime.current <= evaluation_cards_submit_end_date
    end

    # Public: Checks whether the project is inside the time window to be reevaluated
    #
    # returns Boolean
    def withing_reevaluation_time?
      return unless appeal_start_date
      return unless reevaluation_publish_date

      appeal_start_date <= DateTime.current  && DateTime.current <= reevaluation_publish_date
    end

    # Public: Checks whether the project is inside the time window to be reevaluated by verifiers
    #
    # returns Boolean
    def withing_verificators_reevaluation_time?
      return unless reevaluation_cards_submit_end_date

      DateTime.current <= reevaluation_cards_submit_end_date
    end

    # Public: Checks whether the project is inside the time window for sending notifications to authors.
    #
    # returns Boolean
    def within_status_change_notification_time?
      return unless status_change_notifications_sending_end_date

      DateTime.current <= status_change_notifications_sending_end_date
    end

    # Public: Checks whether the project is inside the time window to submit appeal.
    #
    # returns Boolean
    def within_appeal_time?
      return unless appeal_start_date
      return unless appeal_end_date
      # return false unless rejected?
      #
      appeal_start_date <= DateTime.current && DateTime.current <= appeal_end_date && evaluation_publish_date <= DateTime.current
    end

    # Public: Checks whether the project is inside the time window to show evaluation.
    #
    # returns Boolean
    def can_show_evaluation?
      return false unless evaluation_publish_date
      return false unless formal_evaluation
      # return false unless meritorical_evaluation
      return false if draft?

      evaluation_publish_date < DateTime.current
    end

    # Public: Checks whether the project is inside the time window to show reevaluation.
    #
    # returns Boolean
    def can_show_reevaluation?
      return false unless reevaluation_publish_date
      return false unless reevaluation
      return false if draft?

      reevaluation_publish_date < DateTime.current
    end

    # Public: Check if user can generate endorsment list,
    # only in submitting time untilr evaluation date, only for published status
    # returns Boolean
    def can_generate_endorsement_list?
      published_state? && DateTime.current <= evaluation_publish_date
    end

    # Public: Check if user can generate posters
    # true - during voting process, after voting number is set
    # returns Boolean
    def can_generate_posters?
      # Removed for show posters after voting number was generated in project before start date of voting
      voting_number.present? && time_for_posters?
    end

    # Public: returns last implementation body (Implementations do not require body)
    def last_implementation_body
      return 'Brak aktualizacji' if implementations.visible.none?

      implementations.visible.last&.body
    end

    # Public: checkingif projects has any implementation photos
    #
    # returns Boolean
    def with_implementation_photos?
      implementation_photos.any?
    end

    # Public: Override Commentable concern method `users_to_notify_on_comment_created`
    def users_to_notify_on_comment_created
      authors
    end

    # only to be verified at the project's evaluation step
    def with_invalid_budget?
      if admin_changes
        new_budget_value = admin_changes['project_attrs']['budget_value']
        # we check that after acceptance the value of the budget will not be zeroed out
        return true if new_budget_value.blank?

        # we check that after acceptance the value of the budget will not exceed the limit
        return true if new_budget_value.to_i > participatory_space.limit_for_scope(scope)
      end

      # check if the current value of the budget is empty or if it will not exceed the limit, if there were previously accepted changes
      return true if budget_value.blank? || exceeds_limit?

      false
    end

    private

    # Private: checks if project was copied from other component
    def copied_from_other_component?
      linked_resources(:projects, "copied_from_component").any?
    end

    # overwritten for migration
    def find_and_update_descendants; end
  end
end

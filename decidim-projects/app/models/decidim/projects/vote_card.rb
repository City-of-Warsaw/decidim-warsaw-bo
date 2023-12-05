# frozen_string_literal: true

module Decidim
  module Projects
    # Vote is the model representing vote card for user, supports voting process on Projects
    class VoteCard < ApplicationRecord
      include Decidim::HasComponent
      include Decidim::Loggable
      include Decidim::Traceable

      module STATUSES
        LINK_SENT = 'link_sent' # oczekuje na aktywację – karta, dla której został wysyłany link, ale głosowanie nie zostało zakończone - default for citizens
        WAITING = 'waiting' # niepotwierdzony – papierowa karta wprowadzona do systemu, oddana do akceptacji Koordynatora - default for ad_users
        SUBMITTED = 'submitted' # niezweryfikowany/złożony/oddany - karta, która została zlozona (elektronicznie lub papierowo), moze byc nie wypelniona poprawnie, oczekuje tez na porownanie z baza danych
        VALID = 'valid' # ważny – karta, której numer PESEL znajduje się w bazie służącej do weryfikacji głosujących oraz imię i nazwisko jest zgodne z tą bazą
        PESEL_NOT_VERIFIED = 'pesel_not_verified' # niezweryfikowany PESEL – karta, której numer PESEL głosującego nie znajduje się w bazie służącej do weryfikacji głosujących
        NAME_NOT_VERIFIED = 'name_not_verified' # niezweryfikowane imię i nazwisko – karta, której numer PESEL głosującego znajduje się w bazie służącej do weryfikacji głosujących, ale podane imię i nazwisko jest inne niż te w zawarte w bazie
        INVALID = 'invalid' # nieważny – karty wprowadzone papierowo, dla których nie zostały wypełnione pola obowiązkowe
                            # lub karty wprowadzone papierowo, dla których zaznaczono przynajmniej jedno pole wyboru, dotyczące nieważności głosu
                            # lub karty, w których numer PESEL został użyty więcej niż 1 raz
      end


      ADMIN_STATES_FOR_SEARCH = %w(link_sent waiting submitted valid pesel_not_verified name_not_verified invalid).freeze # votes states for search in admin panel
      ADMIN_STATUS_FOR_UPDATE = %w(waiting submitted valid pesel_not_verified name_not_verified invalid).freeze # votes states for update in admin panel
      STATUSES_ACCEPTED = %w{submitted valid pesel_not_verified name_not_verified invalid}.freeze # votes statuses for checking if pesel was used

      scope :paper_votes,      -> { where(is_paper: true) }
      scope :waiting_votes,    -> { where(status: STATUSES::WAITING) }
      scope :accepted_votes,   -> { where(status: STATUSES_ACCEPTED) }
      scope :for_coordinators, -> { paper_votes.where(status: [STATUSES::WAITING, STATUSES::SUBMITTED]) }
      scope :with_pesel,       -> { where.not(pesel_number: nil) }
      scope :with_active_link, -> { where(status: STATUSES::LINK_SENT) }
      scope :for_verification, -> { where(status: [STATUSES::PESEL_NOT_VERIFIED, STATUSES::NAME_NOT_VERIFIED]) }

      scope :without_sent,  -> { where.not(status: STATUSES::LINK_SENT) } # scope for showing all voting cards for project
      scope :submitted,     -> { where.not(status: [STATUSES::LINK_SENT, STATUSES::WAITING]) } # all that were successfully submitted
      scope :valid,         -> { where(status: STATUSES::VALID) }
      scope :not_verified,  -> { where(status: [STATUSES::PESEL_NOT_VERIFIED, STATUSES::NAME_NOT_VERIFIED]) }
      scope :invalid,       -> { where(status: STATUSES::INVALID) }
      scope :in_paper,      -> { submitted.where(is_paper: true) }
      scope :electronic,    -> { submitted.where(is_paper: false) }
      scope :with_district_votes, -> { where('district_projects_count > 0') }
      scope :with_global_votes,   -> { where('global_projects_count > 0') }

      belongs_to :scope,
                 class_name: "Decidim::Scope",
                 foreign_key: :scope_id,
                 optional: true
      belongs_to :author,
                 class_name: "Decidim::User",
                 foreign_key: :author_id,
                 optional: true
      belongs_to :publisher,
                 class_name: "Decidim::User",
                 foreign_key: :publisher_id,
                 optional: true
      belongs_to :resend_email_user,
                 class_name: "Decidim::User",
                 foreign_key: :resend_email_user_id,
                 optional: true
      has_many :project_votes,
               class_name: "Decidim::Projects::ProjectVote",
               foreign_key: :decidim_projects_vote_card_id,
               dependent: :destroy
      has_many :projects,
               through: :project_votes,
               class_name: "Decidim::Projects::Project",
               source: :project
      has_many :statistics,
               class_name: "Decidim::Projects::VoteStatistic",
               dependent: :destroy

      attr_accessor :pesel_warnings
      delegate :organization, :participatory_space, to: :component
      delegate :global_scope_projects_voting_limit, :district_scope_projects_voting_limit, to: :participatory_space

      before_create :generate_voting_token

      def self.clear_user_data
        update_all(
          voting_token: '',
          first_name: '',
          last_name: '',
          email: '',
          pesel_number: '',
          street: '',
          street_number: '',
          flat_number: '',
          zip_code: '',
          city: '',
          projects_in_districts_scope:'',
          projects_in_global_scope:'',
          cleared_data: true
        )
      end

      def clear_user_data_for_unfinished_voting!
        update(
          first_name: '',
          last_name: '',
          pesel_number: '',
          street: '',
          street_number: '',
          flat_number: '',
          zip_code: '',
          projects_in_districts_scope:'',
          projects_in_global_scope:'',
          city: 'Warszawa' # set default city
        )
      end

      def district_projects
        @district_projects ||= projects.in_district_scope
      end

      def global_projects
        @global_projects ||= projects.in_global_scope
      end

      def update_verification_results
        voter = Decidim::Projects::Voter.find_by(pesel: pesel_number&.downcase)

        verification_results = {
          # 'Koszt projektów dzielnicowych',
          district_projects_cost: district_projects.sum(:budget_value),
          # 'Koszt projektów ogólomiejskich',
          global_projects_cost: district_projects.sum(:budget_value),
          # Łączny koszt
          projects_cost: district_projects.sum(:budget_value) + district_projects.sum(:budget_value),
          # Numery projektów ogólnomiejskich
          global_projects_numbers: global_projects.map(&:esog_number).join(','),
          # Numery projektów dzielnicowych
          district_projects_numbers: district_projects.map(&:esog_number).join(','),
          # Koszty projektów ogólnomiejskich
          global_projects_cost_list: global_projects.map(&:budget_value).join(','),
          # Koszty projektów dzielnicowych
          district_projects_costs_list: district_projects.map(&:budget_value).join(','),
          voter_first_name: voter&.first_name,
          voter_last_name: voter&.last_name
        }
        update_column :verification_results, verification_results
      end

      # update global and district projects count
      def update_counters
        update_columns(
          global_projects_count: global_projects.count,
          district_projects_count: district_projects.count
        )
      end

      def district_projects_ids
        district_projects.pluck(:id)
      end

      def global_projects_ids
        global_projects.pluck(:id)
      end

      def author_name
        is_paper ? author.ad_full_name : "-"
      end

      def publisher_name
        is_paper && publisher ? publisher.ad_full_name : "-"
      end

      # Public method
      def last_statistic
        statistics.create if statistics.none?

        statistics.last
      end

      # Public method
      def last_active_statistic
        stat = statistics.last
        stat if stat.finished_voting_time.nil?
      end

      # Public method retrieve last active statistic or create it if there is no one.
      #
      # Returns object - VoteStatistic
      def retrieve_last_statistic(link_sent = false)
        if link_sent == 'true'
          clear_user_data_for_unfinished_voting!
        else
          return last_active_statistic if last_active_statistic.present?
        end
        statistics.create
      end

      # Public method setting finished_voting_time for all of the open statistics.
      # This method is used, when User publishes his vote to close all of the hanging statistics
      def close_all_opened_statistics!
        statistics.close_all!
      end

      # Public method that finishes last active statistic for voting
      def finish_active_statistic!
        return unless last_active_statistic

        last_active_statistic.finish!
      end

      def voting_finish_time
        voting_finished? ? last_statistic.finished_voting_time : ""
      end

      def voting_finished?
        !voting_in_progress?
      end

      def voting_in_progress?
        [STATUSES::LINK_SENT, STATUSES::WAITING].include?(status)
      end

      def submitting_method
        is_paper ? 'Papierowo' : 'Elektronicznie'
      end

      def district_projects_cost_summary
        projects.in_district_scope.sum(:budget_value)
      end

      def global_scope_projects_cost_summary
        projects.in_global_scope.sum(:budget_value)
      end

      def scope_budget_value(scope_id)
        participatory_space.scope_budgets.find_by(decidim_scope_id: scope_id)&.budget_value
      end

      def global_scope_budget_value
        participatory_space.budget_value_for(Decidim::Scope.citywide)
      end

      def age
        return unless valid_pesel_number

        pesel.age
      end

      def age_in(a,b)
        return unless valid_pesel_number

        'Tak' if a <= pesel.age && pesel.age <= b
      end

      def birth_date
        return unless valid_pesel_number

        pesel.birth_date
      end

      def gender
        return unless valid_pesel_number

        pesel.gender
      end

      # Method used for paper votes show view to indicate that no data can be taken from pesel
      # as it is invalid
      #
      # returns Boolean
      def valid_pesel_number
        return false unless pesel_number.present?

        pesel.valid?
      end

      def pesel_warnings
        pesel.warnings_collection
      end

      # Public method
      #
      # Method defines Admin Log Presenter class
      def self.log_presenter_class_for(_log)
        Decidim::Projects::AdminLog::VoteCardPresenter
      end

      def self.generate_card_number(component)
        count = self.where(decidim_component_id: component.id).where.not(card_number: nil).count

        "#{count + 1}/#{component.participatory_space.edition_year}"
      end

      # generating random voting token
      #
      # returns String
      def generate_voting_token
        self.voting_token = SecureRandom.hex(36)
        while VoteCard.find_by(voting_token: voting_token)
          self.voting_token = SecureRandom.hex(36)
        end
      end

      def pesel
        Decidim::Projects::PeselValue.new(self, pesel_number)
      end

      def to_param
        voting_token.presence || id
      end
    end
  end
end

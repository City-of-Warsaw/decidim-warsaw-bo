# frozen_string_literal: true

class OldModels::Project
  include Virtus.model

  attribute :id, Integer
  attribute :order, Integer
  attribute :number, String
  attribute :title, String
  attribute :creatorId, Integer
  attribute :taskGroupId, Integer
  attribute :status, Integer
  attribute :created, String # Date - 2021-02-01 12:47:54
  attribute :isPaper, Boolean
  attribute :shortDescription, String
  attribute :mainRegionId, Integer
  attribute :localization, String
  attribute :local, String
  attribute :regionId, Integer
  attribute :localizationExtra, String
  attribute :availabilityDescription, String
  attribute :description, String
  attribute :universalDesign, Integer
  attribute :universalDesignArgumentation, String
  attribute :argumentation, String
  attribute :costSummary, String
  attribute :cost, Decimal
  attribute :hasCostOfOperation, Boolean
  attribute :creatorCostOfOperation, String
  attribute :costOfOperation, Decimal
  attribute :producerList, String
  attribute :remarks, String
  attribute :votingTotalVotes, Integer
  attribute :votingPercentOfSupport, Decimal
  attribute :cocreators, [Integer]
  attribute :categories, []
  attribute :classificationOther, String
  attribute :recipients, [String]
  attribute :recipientOther, String
  attribute :projectLevel, String
  attribute :mapPins, [OldModels::MapPin]
  attribute :reasonNegativeVerification, String
  attribute :projectRealizationEffects, String

  attribute :history, [OldModels::History]
  attribute :comments, [OldModels::Comment]
  attribute :assignment, OldModels::Assignment

  attribute :attachments, [OldModels::Attachment]
  attribute :verification,  OldModels::Verification
  attribute :privateFiles, [OldModels::PrivateFile]
  attribute :creatorAgreementFiles, [OldModels::CreatorAgreementFile]
  attribute :taskVerificationRecall, OldModels::TaskVerificationRecall
  attribute :realization, OldModels::Realization

  def find_new
    Decidim::Projects::Project.find_by old_id: id
  end

  def build_project(edition, user, region)
    p = Decidim::Projects::Project.new
    p.component = edition.components.first
    p.edition_year = edition.edition_year
    p.region = region

    p.formal_result = verification.formalResult.blank? ? nil : verification.formal_result_true?
    p.meritorical_result = verification.meritResult.blank? ? nil : verification.merit_result_true?
    p.reevaluation_result = verification.reevaluationResult.blank? ? nil : verification.reevaluation_result_true?

    raise NoUserImporterError.new("brak usera") unless user
    p.add_coauthor(user, confirmation_status: 'confirmed', coauthorship_acceptance_date: Date.current)

    update_attrs(p)
    p
  end

  def update_project(p)
    update_attrs(p)
    p
  end

  def update_attrs(p)
    p.old_id = id
    p.voting_number = order
    p.esog_number = number

    p.title = title

    p.state = get_state
    p.created_at = DateTime.parse(created)
    p.published_at = DateTime.parse(created) if status != 1
    p.is_paper = isPaper

    p.short_description = shortDescription
    p.localization_info = localization
    p.localization_additional_info = localizationExtra
    p.availability_description = availabilityDescription
    p.body = description
    p.universal_design = get_universal_design
    p.universal_design_argumentation = universalDesignArgumentation
    p.justification_info = argumentation

    p.votes_count = votingTotalVotes
    p.votes_percentage = votingPercentOfSupport

    p.locations = get_locations

    p.budget_description = costSummary
    p.budget_value = cost

    if hasCostOfOperation
      p.future_maintenance = hasCostOfOperation
      p.future_maintenance_description = creatorCostOfOperation
      p.future_maintenance_value = (costOfOperation && costOfOperation < 0 ? 0 : costOfOperation)
    end
    p.negative_verification_reason = reasonNegativeVerification
    p.project_implementation_effects = projectRealizationEffects

    p.verification_status = 'imported'

    p.chosen_for_voting = status == 5 || status == 6  || status == -3
    p.chosen_for_implementation = status == 6

    if realization&.revoked
      p.implementation_status = 0
    else
      p.implementation_status = realization&.state
    end
  end

  def rn_to_br(str)
    str.gsub("\r\n", "<br/>") if str.present?
  end

  def get_universal_design
    # 0 - no, 1 – yes, 2 – no answer
    return if universalDesign == 2

    universalDesign == 1
  end

  def get_scope(global_district, districts)
    if projectLevel && projectLevel == "Ogólnomiejski"
      global_district
    else
      districts[mainRegionId]
    end
  end

  # Project status [int] in the system:
  # • -3 - Not selected by vote
  # • -2 - Withdrawn by the author
  # • -1 - Negatively rated
  # • 3 - Submitted
  # • 4 - Evaluation in progress
  # • 5 - Allowed to vote
  # • 6 - Selected by vote - Winning project
  def get_state
    case status
    when "" then Decidim::Projects::Project::POSSIBLE_STATES::DRAFT
    when nil then Decidim::Projects::Project::POSSIBLE_STATES::DRAFT
    when -3 then Decidim::Projects::Project::POSSIBLE_STATES::NOT_SELECTED
    when -2 then Decidim::Projects::Project::POSSIBLE_STATES::WITHDRAWN
    when -1 then Decidim::Projects::Project::POSSIBLE_STATES::REJECTED
    when 1 then Decidim::Projects::Project::POSSIBLE_STATES::DRAFT
    when 3 then Decidim::Projects::Project::POSSIBLE_STATES::PUBLISHED

    when 2 then Decidim::Projects::Project::POSSIBLE_STATES::EVALUATION
    when 4 then Decidim::Projects::Project::POSSIBLE_STATES::EVALUATION

    when 5 then Decidim::Projects::Project::POSSIBLE_STATES::ACCEPTED
    when 6 then Decidim::Projects::Project::POSSIBLE_STATES::SELECTED
    else
      raise "brak mapowania dla statusu: #{status}"
    end
  end

  def get_locations
    return {} unless mapPins.any?

    locations = {}
    mapPins.each do |pin|
      locations["#{rand(Time.current.to_i)}"] = {
        lat: pin.lat,
        lng: pin.lng,
        display_name: "lat: #{pin.lat}, lng: #{pin.lng}"
      }
    end
    locations
  end
end


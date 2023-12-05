# frozen_string_literal: true

class OldModels::ProjectVersion
  include Virtus.model

  attribute :title, String
  attribute :shortDescription, String
  attribute :local, String
  attribute :global, Boolean
  attribute :mainRegionId, Integer
  attribute :localization, String
  attribute :localizationExtra, String
  attribute :classifications, [String]
  attribute :recipients, [String]
  attribute :classificationOther, String
  attribute :recipientOther, String
  attribute :availabilityDescription, String
  attribute :description, String
  attribute :argumentation, String
  attribute :costSummary, String
  attribute :cost, Decimal
  attribute :creatorCostOfOperation, String
  attribute :costOfOperation, Decimal
  attribute :hasCostOfOperation, Boolean
  attribute :status, Integer
  attribute :taskFormAttachments, [Integer]
  attribute :hasRequiredAttachments, Boolean
  attribute :hasOwnerAgreement, Boolean
  attribute :progress, Boolean
  attribute :isRealizationRevoked, Boolean
  attribute :realizationDescription, String
  attribute :realizedBy, String
  attribute :modifiedRealization, String
  attribute :costVerified, Decimal
  attribute :universalDesign, Integer
  attribute :universalDesignArgumentation, String

  def categories
    classifications
  end

  def build_project(edition, creator, region)
    p = Decidim::Projects::Project.new
    p.component = edition.components.first
    p.edition_year = edition.edition_year
    p.region = region

    raise NoUserImporterError.new("brak usera") unless creator
    p.add_coauthor(creator, confirmation_status: 'confirmed', coauthorship_acceptance_date: Date.current)

    update_attrs(p)
    p
  end

  def update_project(p)
    update_attrs(p)
    p
  end

  def update_attrs(p)
    p.title = title
    p.short_description = shortDescription
    p.localization_info = localization
    p.localization_additional_info = localizationExtra
    p.availability_description = availabilityDescription
    p.body = description
    p.justification_info = argumentation
    p.budget_description = costSummary
    p.budget_value = (cost && cost.to_f >= 2973159271576 ? 9999999999.99 : cost)
    p.future_maintenance_description = creatorCostOfOperation
    p.future_maintenance_value = costOfOperation
    p.future_maintenance = hasCostOfOperation
    p.state = get_state
    p.universal_design = get_universal_design
    p.universal_design_argumentation = universalDesignArgumentation.presence || nil
  end

  def get_universal_design
    # 0 - no, 1 – yes, 2 – no answer } universal_design
    return if universalDesign == 2

    universalDesign == 1
  end

  def get_scope(global_district, districts)
    if global
      global_district
    else
      districts[mainRegionId]
    end
  end

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
end


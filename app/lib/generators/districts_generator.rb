# frozen_string_literal: true

module Generators
  class DistrictsGenerator
    include DecidimDictionaries

    attr_reader :district_wide_type, :city_wide_type

    def initialize
      @organization = Decidim::Organization.first
    end

    def call
      find_or_generate_district_wide_type
      find_or_generate_city_wide_type
      generate_citywide_scope
      generate_scopes
    end

    def destroy_all
      Decidim::ScopeType.where("name ->> 'pl' = ?", "Dzielnicowy").first.destroy
      Decidim::ScopeType.where("name ->> 'pl' = ?", "Ogólnomiejski").first.destroy
      # Decidim::AdminExtended::Department.destroy_all
      # Decidim::Scope.destroy_all
    end

    private

    # CdshBoSeader.new.find_or_generate_district_wide_type
    def find_or_generate_district_wide_type
      @district_wide_type ||= begin
                                Decidim::ScopeType.where("name ->> 'pl' = ?", "Dzielnicowy").first ||
                                  Decidim::ScopeType.create!(
                                    decidim_organization_id: @organization.id,
                                    name: { "pl": "Dzielnicowy" },
                                    plural: { "pl": "Dzielnicowe" },
                                  )
                              end
    end

    def find_or_generate_city_wide_type
      @city_wide_type ||= begin
                            Decidim::ScopeType.where("name ->> 'pl' = ?", "Ogólnomiejski").first ||
                              Decidim::ScopeType.create!(
                                decidim_organization_id: @organization.id,
                                name: { "pl": "Ogólnomiejski" },
                                plural: { "pl": "Ogólnomiejskie" },
                              )
                          end
    end

    def generate_citywide_scope
      return if Decidim::Scope.where("name ->> 'pl' = ?", 'Ogólnomiejski').first

      Decidim::Scope.create!(
        decidim_organization_id: @organization.id,
        name: { "pl": "Ogólnomiejski" },
        scope_type_id: @city_wide_type.id,
        parent_id: nil,
        code: "om"
      )
    end

    # generuje ScopeType: "ogólnomiejski" i "dzielnicowy"
    def generate_scopes
      district_list.each do |district|
        next if Decidim::Scope.where("name ->> 'pl' = ?", district[:name]).first

        Decidim::Scope.create!(
          decidim_organization_id: @organization.id,
          name: { "pl": district[:name] },
          scope_type_id: @district_wide_type.id,
          parent_id: nil,
          code: district[:code]
        )
      end
    end

  end
end
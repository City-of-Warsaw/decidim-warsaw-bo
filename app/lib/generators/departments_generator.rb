# frozen_string_literal: true

module Generators
  class DepartmentsGenerator
    include DecidimDictionaries

    # Generators::DepartmentsGenerator.new.call
    def call
      district_list.each do |item|
        generate_department(item)
      end
      biura.each do |item|
        generate_department(item)
      end
    end

    def generate_department(item)
      Decidim::AdminExtended::Department.create!(name: item[:name], ad_name: item[:symbol].downcase)
    end

    def reset_all
      ActiveRecord::Base.connection.execute('TRUNCATE "public"."decidim_admin_extended_department_delegations" RESTART IDENTITY CASCADE;')
      ActiveRecord::Base.connection.execute('TRUNCATE "public"."decidim_admin_extended_departments" RESTART IDENTITY CASCADE;')
    end
  end
end
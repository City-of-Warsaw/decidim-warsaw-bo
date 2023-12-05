# frozen_string_literal: true

module Importers
  class ImporterError < StandardError; end
  class NoUserImporterError < ImporterError; end
  class NoHistoryUserImporterError < ImporterError; end

  class BaseImporter

    attr_accessor :data, :file_path

    # Public: returns Object - Organization of the Project
    def organization
      @organization ||= Decidim::Organization.first
    end

    def import_root_path
      if Rails.env.development?
        # '/Users/przemad/BO-dane/migration-2022-11-07'
        # '/Users/przemad/BO-dane/migration-2022-10-14'
        '/Users/przemad/BO-dane/migration-2022-11-07'
      else
        # '/var/www/decidim/migracja/migration-2022-05-02'
        '/var/www/decidim/migracja/migration-2022-10-14'
      end
    end

    def import_files_path; end

    def read_data_from_file
      file = File.read(@file_path)
      @data = JSON.parse file
      true
    end

    def find_old(old_id)
      read_data_from_file if data.blank?
      d = data.select{ |p| p['id'] == old_id.to_s }
      old_model.new(d.first)
    end

    def find_old_by_index(index)
      read_data_from_file if data.blank?
      data.each_with_index do |d, i|
        next if i < index

        return old_model.new(d)
      end
    end

    # Importers::ProjectsImporter.new.test_field('isPaper')
    # Importers::ProjectsImporter.new.test_field('status', 50)
    # Importers::ProjectsImporter.new.test_field('projectLevel', 50)
    def test_field(field_name, limit=nil)
      read_data_from_file
      data = limit ? @data.first(limit) : @data
      data.each_with_index do |d, index|
        ap d[field_name]
      end
      true
    end

    # Typy logow sa w message:
    # - user-email-problem - email nie znaleziony lub poprawiony
    # - user-duplicated - znaleziony duplikat usera,
    # - project - no history, no user - brak ulasciciela
    # - no-user-in-process_comments, user_id:
    # - no-user-in-process_realizations, user_id:
    def add_log(item, message = nil, body = nil)
      Decidim::Projects::ImportLog.create(old_id: item.id, resource_type: item.class.to_s, message: message, body: body)
    end

    def create_missing_user(old_user_id)
      Decidim::Projects::SimpleUser.create(
        old_id: old_user_id,
        organization: organization,
        first_name: nil,
        last_name: nil,
        anonymous_number: rand(Time.current.to_i),

        # agreements
        show_my_name: false,
        inform_me_about_proposal: false,
        email_on_notification: false
      )
    end
  end
end

# frozen_string_literal: true

class Importers::UsersImporter < Importers::BaseImporter

  attr_accessor :data, :problems, :old_problems

  def initialize
    @file_name = 'users-list-v1.json'
    @file_path = "#{import_root_path}/#{@file_name}"
    @organization = Decidim::Organization.first
    @problems = []
    @old_problems = []
  end

  def call(from_index = nil)
    read_data_from_file
    ap Benchmark.realtime { process_file_data(from_index) }
    true
  end

  def process_file_data(from_index = nil)
    Decidim::User.transaction do
      PaperTrail.request(enabled: false) do
        data.reverse.each_with_index do |d, index|
          next if from_index && index < from_index

          old_user = OldModels::User.new(d)
          ap "#{index}, user-id: #{old_user.id}; name: #{old_user.name}, displayName: #{old_user.displayName}; email: #{old_user.email}"

          if old_user.simple_user?
            ap 'simple user !!'
            user = old_user.build_simple_user(@organization)
            user.save
            @old_problems << old_user
            add_log(old_user, 'user-email-problem', "email: #{old_user.email}")
            next
          end

          user = old_user.build_user(@organization)
          email = old_user.fixed_email
          ap "email: #{old_user.email} => #{old_user.fixed_email}"
          original = Decidim::User.find_by(email: email)
          if original
            ap 'duplikat!!'
            add_log(old_user, 'user-duplicated')
            all_old_ids = if original.all_old_ids.blank?
                            user.old_id
                          else
                            (original.all_old_ids.split(',') + [user.old_id]).join(',')
                          end
            original.update_column(:all_old_ids, all_old_ids)

            @problems << old_user
          else
            user.save!
          end
        end
      end
    end
    true
  end

  def fix_gender
    PaperTrail.request(enabled: false) do
      data.reverse.each_with_index do |d, index|
        ap "index: #{index}"
        old_user = OldModels::User.new(d)
        next if old_user.displayName.blank?
        next if old_user.displayName != "Mieszkaniec" && old_user.displayName != "Mieszkanka"

        user = Decidim::User.find_by old_id: old_user.id
        user.update_column(:gender, old_user.get_gender) if user
      end
    end
    true
  end

  def test_run
    # decidim_searchable_resources
    # decidim_users
    # decidim_projects_simple_users
    # decidim_action_logs
    i = Importers::UsersImporter.new
    i.call

    i.read_data_from_file
    i.data.size # wszystkich 25512 => 26223; nowy: 27521
  end

  def xx2
    arr = []
    list = i.problems.map(&:email).uniq
    1.tap do
      i.data.each_with_index do |d, index|
        ap(index) if index%1000 == 0
        item = OldModels::User.new(d)
        next if item.email.blank? || ["***", "502824825", "503677898", "-", "606785755", "matmieciek", "Nie posiadam", "brak", "537489363"].include?(item.email)
        # user = item.build_user(nil)
        email = item.fixed_email.rstrip.lstrip
        if list.include?(email)
          arr << item
        end
      end
    end

    1.tap do
      File.open("konta-powtorzone2.csv", 'w') do |file|
        file.write("index; id; imię; nazwisko; email; nr tel; name; status \r\n")
        arr.sort{|x,y| x.email <=> y.email}.each_with_index do |u, index|
          line = "#{index}; #{u.id}; #{u.firstName}; #{u.lastName}; #{u.email}; #{u.phone}; #{u.name}; #{u.status}\r\n"
          file.write(line)
        end
      end
    end
  end


  def xxx
    # BOM = "\377\376" # Byte Order   Mark

    1.tap do
      File.open("konta-bez-maili.csv", 'w') do |file|
        file.write("index; id; imię; nazwisko; email; nr tel; name; status \r\n")
        i.old_problems.each_with_index do |u, index|
          line = "#{index}; #{u.id}; #{u.firstName}; #{u.lastName}; #{u.email}; #{u.phone}; #{u.name}\r\n"
          file.write(line)
        end
      end
    end

    # str = []
    # str << "index; id; imię; nazwisko; email; nr tel; name \r\n"
    # Decidim::User.where(email: i.problems.map(&:email).uniq).each_with_index do |u, index|
    #   str <<  "#{index}; #{u.old_id}; #{u.first_name}; #{u.last_name}; #{u.email}; #{u.phone_number}; #{u.name}\r\n"
    # end
    # File.open("konta-powtorzone2.csv", 'w') do |file|
    #   file.write(BOM + str.join.encode("utf-16le").force_encoding("utf-8"))
    # end

    1.tap do
      File.open("konta-powtorzone.csv", 'w') do |file|
        file.write("index; id; imię; nazwisko; email; nr tel; name; status \r\n")
        Decidim::User.where(email: i.problems.map(&:email).uniq).each_with_index do |u, index|
          line = "#{index}; #{u.old_id}; #{u.first_name}; #{u.last_name}; #{u.email}; #{u.phone_number}; #{u.name}; ?\r\n"
          file.write(line)
        end

        i.problems.each_with_index do |u; index|
          line = "#{index}; #{u.id}; #{u.first_name}; #{u.last_name}; #{u.email}; #{u.phone_number}; #{u.name}; #{u.status}\r\n"
          file.write(line)
        end
      end
    end
  end


  # Importers::UsersImporter.new.remove_all_data
  def remove_all_data
    Decidim::User.where.not(old_id: nil).destroy_all
    # Decidim::User.where.not(old_id: nil).delete_all
    # reset_table
    # reset_index
  end

  # Importers::UsersImporter.new.mask_users_emails
  def mask_users_emails
    1.tap do
      Decidim::User.transaction do
        PaperTrail.request(enabled: false) do
          Decidim::User.where.not(old_id: nil).each do |user|
            user.update_column :email, "bo-example-#{user.old_id}@codeshine.com"
          end
        end
      end
    end
    true
  end


  # private

  def reset_table
    # ActiveRecord::Base.connection.execute("TRUNCATE TABLE decidim_users CASCADE;")
    ActiveRecord::Base.connection.execute('TRUNCATE "public"."decidim_searchable_resources" RESTART IDENTITY CASCADE;')
    ActiveRecord::Base.connection.execute('TRUNCATE "public"."decidim_users" RESTART IDENTITY CASCADE;')
    ActiveRecord::Base.connection.execute('TRUNCATE "public"."decidim_projects_simple_users" RESTART IDENTITY CASCADE;')
    ActiveRecord::Base.connection.execute('TRUNCATE "public"."decidim_action_logs" RESTART IDENTITY CASCADE;')
    ActiveRecord::Base.connection.execute('TRUNCATE "public"."decidim_coauthorships" RESTART IDENTITY CASCADE;')
    ActiveRecord::Base.connection.execute('TRUNCATE "public"."decidim_assembly_user_roles" RESTART IDENTITY CASCADE;')
    ActiveRecord::Base.connection.execute('TRUNCATE "public"."decidim_participatory_process_user_roles" RESTART IDENTITY CASCADE;')
    ActiveRecord::Base.connection.execute('TRUNCATE "public"."decidim_projects_project_user_assignments" RESTART IDENTITY CASCADE;')
    ActiveRecord::Base.connection.execute('TRUNCATE "public"."decidim_user_group_memberships" RESTART IDENTITY CASCADE;')
    ActiveRecord::Base.connection.execute('TRUNCATE "public"."decidim_user_blocks" RESTART IDENTITY CASCADE;')
  end

  def reset_index
    ActiveRecord::Base.connection.execute("SELECT setval('decidim_users_id_seq', max(id)) FROM decidim_users;")
  end


  def test
    organization = Decidim::Organization.first
    i = Importers::UsersImporter.new
    i.read_data_from_file
    ap d = i.data[1200]
    item = OldModels::User.new(d)
    user = item.build_user(organization)
    user.valid?
    ap user.errors

    Importers::UsersImporter.new.test_field('name', 250)

    Decidim::User.where.not(old_id: nil).delete_all
    Importers::UsersImporter.new.remove_all_data


    "2465, user-id: 26081; name: autor_601aa8f2da85b, displayName: Antoni  Krugliński"
    Importers::UsersImporter.new.call
  end

end
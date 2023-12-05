# frozen_string_literal: true

require 'decidim/core/test/factories'

FactoryBot.define do
  factory :budget_info_group, class: 'Decidim::AdminExtended::BudgetInfoGroup' do
    name { 'Name' }
    subtitle { 'Subtitle' }
    published { true }
    weight { 1 }
  end

  factory :budget_info_position, class: 'Decidim::AdminExtended::BudgetInfoPosition' do
    association :budget_info_group, factory: :budget_info_group
    name { 'name' }
    description { 'description' }
    amount { 'amount' }
    published { true }
    weight { 1 }
    on_main_site { true }
  end

  factory :contact_info_group, class: 'Decidim::AdminExtended::ContactInfoGroup' do
    name { 'name' }
    subtitle { 'subtitle' }
    published { true }
    weight { 1 }
  end

  factory :contact_info_position, class: 'Decidim::AdminExtended::ContactInfoPosition' do
    association :contact_info_group, factory: :contact_info_group
    name { 'name' }
    position { 'position' }
    phone { 'phone' }
    email { 'name@mail.com' }
    published { true }
    weight { 1 }
  end

  factory :faq_group, class: 'Decidim::AdminExtended::FaqGroup' do
    title { 'title' }
    subtitle { 'subtitle' }
    published { true }
    weight { 1 }
  end

  factory :faq, class: 'Decidim::AdminExtended::Faq' do
    association :faq_group, factory: :faq_group
    title { 'title' }
    content { 'content' }
    published { true }
    weight { 1 }
  end

  factory :department, class: Decidim::AdminExtended::Department do
    sequence(:name) { |n| "Department #{n}" }
    active { true }
    # enum department_type:
    # - district: 10
    # - general_municipal_unit: 20
    # - office: 30
    # - district_unit: 40
    department_type { 10 }
  end

  factory :recipient, class: ::Decidim::AdminExtended::Recipient do
    sequence(:name) { |n| "Receipient #{n}" }
    active { true }
  end
end

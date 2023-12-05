# frozen_string_literal: true

module Decidim::Projects
  # Voter represent person who can vote on projects, vote cards are check with voters list
  # to check if pesel, fisrt and last name are the same,
  # voters are imported from CSV file,
  class Voter < ApplicationRecord
  end
end

# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic for aggregate projects authors and coauthors.
    module Admin
      class AggregateAuthors < Rectify::Command
        # Public: Initializes the command.
        #
        # projects - projects collection for aggregation
        def initialize(projects)
          @projects = projects
          @authors = {}
        end

        def call
          aggregate_users
        end

        private

        attr_reader :authors

        # private method
        #
        # aggregate authors and coauthors to collection
        #
        # returns collection of objects
        # [
        #   { 4: { author: object, authors_of: [], authors_of_esog: [] , coauthors_of: [], coauthors_of_esog: [] }}
        # ]
        def aggregate_users
          @projects.each do |p|
            p.coauthorships.each do |c|
              u = c.author

              if authors[u.id]
                if c.coauthor == false
                  authors[u.id][:authors_of] << p.id
                  authors[u.id][:authors_of_esog] << p.esog_number
                else
                  authors[u.id][:coauthors_of] << p.id
                  authors[u.id][:coauthors_of_esog] << p.esog_number
                end
              else
                authors[u.id] = if c.coauthor == false
                                  {
                                    author: u,
                                    authors_of: [p.id],
                                    authors_of_esog: [p.esog_number],
                                    coauthors_of: [],
                                    coauthors_of_esog: []
                                  }
                                else
                                  {
                                    author: u,
                                    authors_of: [],
                                    authors_of_esog: [],
                                    coauthors_of: [p.id],
                                    coauthors_of_esog: [p.esog_number]
                                  }
                                end

              end
            end
          end
          authors
        end
      end
    end
  end
end

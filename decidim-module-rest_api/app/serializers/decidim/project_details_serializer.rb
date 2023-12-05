# frozen_string_literal: true

module Decidim
  class ProjectDetailsSerializer < ActiveModel::Serializer
    type 'project'

    attributes :id,
               :number,
               :title,
               :description,
               :shortDescription,
               :status,
               :submitted,
               :firstName,
               :lastName,
               :lat,
               :lng,
               :classifications,
               :recipients,
               :taskLevel,
               :localization,
               :localizationExtra,
               :pins,
               :availabilityDescription,
               :argumentation,
               :costSummary,
               :universalDesign,
               :universalDesignArgumentation,
               :cost,
               :mainRegionName,
               :history,
               :cocreators,
               :attachments,
               :url,
               :verification,
               :votes,
               :comments,
               :created

    def created
      object.published_at
    end

    def number
      object.esog_number
    end

    def description
      object.body
    end

    def shortDescription
      object.short_description
    end

    # participatory_process_steps:
    # 1.	submitting projects
    # 2.	rating projects
    # 3.	voting
    # 4.	results

    # Występujące statusy:
    # 1.	not selected
    # 2.	withdrawn
    # 3.	rejected
    # 4.	published
    # 5.	evaluation
    # 6.	accepted
    # 7.	selected
    def status
      5
    end

    def submitted
      object.published_at
    end

    def firstName
      author = object.creator_author
      if author && author.show_my_name
        author.first_name
      else
        author.public_name(with_number=false)
      end
    end

    def lastName
      author = object.creator_author
      if author && author.show_my_name
        author.last_name
      else
        author.public_name(with_number=false)
      end
    end

    def lat
      object.main_location['lat'] if object.main_location
    end

    def lng
      object.main_location['lng'] if object.main_location
    end

    def classifications
      object.categories.map{ |item| item.name['pl'] }
    end

    def recipients
      object.recipients.map { |item| item.name }
    end

    def taskLevel
      object.scope.code == 'om' ? 3 : 4
    end

    def localization
      object.localization_info
    end

    def localizationExtra
      object.localization_additional_info
    end

    def pins
      object.locations.map { |k, v| { id: k, lat: v['lat'], lng: v['lng'] } }
    end

    def availabilityDescription
      object.availability_description
    end

    def argumentation
      object.justification_info
    end

    def costSummary
      object.budget_description
    end

    # Projektowanie uniwersalne [tinyint]: 0 (Nie) /1 (Tak) /2 (Brak odpowiedzi)
    def universalDesign
      return 2 if object.universal_design.nil?
      object.universal_design ? 1 : 0
    end

    def universalDesignArgumentation
      object.universal_design_argumentation
    end

    def cost
      object.budget_value
    end

    def mainRegionName
      object.scope.name['pl']
    end

    def history
      []
    end

    def cocreators
      []
    end

    def attachments
      object.public_photos.map{ |photo| { url: photo.big_url, originalName: photo.title["pl"] }}
    end

    def verification
      {
        resultNotes: '',
        attachments: []
      }
    end

    def votes
      0
    end

    def comments
      object.comments.map{ |c| { login: c.signature, createTime: c.created_at, text: c.body['pl'] }}
    end

    def url
      Decidim::ResourceLocatorPresenter.new(object).url
    end

  end
end

# frozen_string_literal: true

module Decidim
  module AdminExtended
    module Admin
      # A form object to search comments for admin
      class CommentSearchForm < Form
        MAX_DAYS_FILTER = 15

        attribute :start_date, Decidim::Attributes::LocalizedDate
        attribute :end_date, Decidim::Attributes::LocalizedDate

        mimic :comment_search

        def find_comments
          comments = Decidim::Comments::Comment.all.select("decidim_comments_comments.*,decidim_moderations.id as moderate_id,
                                                                   CASE WHEN decidim_moderations.hidden_at IS NOT NULL
                                                                        THEN 'Y'
                                                                        ELSE 'N'
                                                                       END as is_comment_hidden")
                                               .joins("LEFT JOIN decidim_moderations ON decidim_moderations.decidim_reportable_id = decidim_comments_comments.id")
          if start_date.present? && end_date.present?
            days_between_date = end_date.mjd - start_date.mjd
            if days_between_date > MAX_DAYS_FILTER
              errors.add(:start_date, 'Maksymalny okres to 15 dni')
            else
              comments = comments.where('DATE(decidim_comments_comments.created_at) >= ? AND DATE(decidim_comments_comments.created_at) <= ?', start_date, end_date)
            end
          else
            comments = comments.where('DATE(decidim_comments_comments.created_at) >= ?', start_date) if start_date.present?
            comments = comments.where('DATE(decidim_comments_comments.created_at) <= ?', end_date) if end_date.present?
          end
          comments.search_default.order(created_at: :desc)
        end
      end
    end
  end
end

# frozen_string_literal: true
module Decidim::AdminExtended
  # Custom helpers for documents
  module Admin::DocumentsHelper
    def user_roles_for(document)
      document.map_roles.map { |e| I18n.t(e, scope: 'activemodel.attributes.document')}.join(', ')
    end

    # return direct link to download blob from ActiveStorage, force HTTPS in staging and proouction
    # use with caution
    def direct_link_to(document)
      ActiveStorage::Current.host ||= if Rails.env.development?
                                        'http://localhost:3000'
                                      else
                                        "https://#{request.host_with_port}"
                                      end
      attachment_blob = document.blob
      direct_url = ActiveStorage::Blob.service.url(
        attachment_blob.key,
        expires_in: 120,
        disposition: "attachment",
        filename: attachment_blob.filename,
        content_type: attachment_blob.content_type
      )
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Exporters
    class RankingListCSVExporter < CSV

      def initialize(collection, serializer, scope)
        @collection = collection
        @serializer = serializer
        @scope = scope
      end

      def export(col_sep = Decidim.default_csv_col_sep)
        data = ::CSV.generate(headers: headers, write_headers: true, col_sep: col_sep) do |csv|
          processed_collection.each do |resource|
            csv << headers.map { |header| custom_sanitize(resource[header]) }
          end
        end
        ExportData.new(data, "csv")
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module AdminExtended
    class StatisticsController < Decidim::AdminExtended::ApplicationController
      include Decidim::FormFactory

      def index
        @form = form(Decidim::AdminExtended::StatisticForm).from_params(params)
        @statistics = AdminExtended::GetStatisticsData.new(@form).call
      end

    end
  end
end

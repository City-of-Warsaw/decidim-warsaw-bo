# frozen_string_literal: true

module Decidim
  module ProcessesExtended
    # Custom helpers, scoped to the processes_extended engine.
    #
    module ApplicationHelper

      # Return dates in HTML format
      # step - actual participatory_process step
      def dates_range(step)
        range = if step.start_date.present? && step.end_date.present?
                  return I18n.l(step.start_date, format: '%Y<br><br>').html_safe if step.system_name == 'realization'

                  if step.start_date.year == step.end_date.year
                    "od #{I18n.l step.start_date, format: '%-d %B'} <br>do #{I18n.l step.end_date, format: '%-d %B %Y'}"
                  else
                    "od #{I18n.l step.start_date, format: '%-d %B %Y'} <br>do #{I18n.l step.end_date, format: '%-d %B %Y'}"
                  end
                elsif step.start_date.present?
                  I18n.l step.start_date, format: '%Y<br><br>'
                elsif step.end_date.present?
                  I18n.l step.end_date, format: '%-d %B %Y<br><br>'
                else
                  '-<br>-<br>'
                end
        range.html_safe
      end

    end
  end
end

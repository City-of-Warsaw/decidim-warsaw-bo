# frozen_string_literal: true

# A ParticipatoryProcess is composed of many steps that hold different
# components that will show up in the depending on what step is currently
# active.
Decidim::ParticipatoryProcessStep.class_eval do

  # oznacza aktywny krok zaleznie od dat etapow
  def active_step?
    start_date && end_date && start_date <= Date.today && Date.today <= end_date
  end
end

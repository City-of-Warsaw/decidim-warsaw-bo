# This migration comes from decidim_processes_extended (originally 20211111221103)
class CreateDecidimProcessesExtendedScopeBudgets < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_processes_extended_scope_budgets do |t|
      t.references :decidim_scope, index: { name: 'index_scope_budgets_on_scope_id' }, foreign_key: true
      t.references :decidim_participatory_process, index: { name: 'index_scope_budgets_on_process_id' }, foreign_key: true

      t.integer :budget_value
      t.integer :max_proposal_budget_value, default: 0
      t.timestamps
    end
  end
end

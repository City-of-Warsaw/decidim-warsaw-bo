class ChangeConfirmedColumnOnCoauthorships < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        add_column :decidim_coauthorships,:confirmation_status, :string, default: 'waiting'
        # updating for already confirmed
         Decidim::Coauthorship.where(confirmed: true).update_all(confirmation_status: 'confirmed')
        remove_column :decidim_coauthorships, :confirmed
      end

      dir.down do
        add_column :decidim_coauthorships, :confirmed, :boolean, default: false
        # updating for already confirmed
        Decidim::Coauthorship.where(confirmation_status: 'confirmed').update_all(confirmed: true)
        remove_column :decidim_coauthorships, :confirmation_status
      end
    end
  end
end
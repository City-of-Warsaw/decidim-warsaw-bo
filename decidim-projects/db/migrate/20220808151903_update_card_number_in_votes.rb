class UpdateCardNumberInVotes < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        if Decidim::Projects::Vote.column_names.include?('card_number')
          Decidim::Projects::Vote.where(card_number: nil).order(created_at: :asc).each do |vote|
            vote.update_column('card_number', Decidim::Projects::Vote.generate_card_number(vote.component))
          end
        end
      end
    end
  end
end

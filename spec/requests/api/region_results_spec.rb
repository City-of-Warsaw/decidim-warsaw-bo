require 'swagger_helper'

RSpec.describe 'api/regionResults', type: :request do

  # path '/rest-api/regionResults' do
  path '/rest-api-no-auth/regionResults' do

    get 'Pobiera wyniki głosowania dla dzielnicy' do
      tags 'RegionResults'
      description 'Pobiera wyniki głosowania dla dzielnicy'
      produces 'application/json'
      parameter name: :groupId, in: :query, type: :integer, required: true
      parameter name: :regionId, in: :query, type: :integer, required: true
      # request_body_example value: { groupId: '2022' }, name: 'basic', summary: 'Request example description'

      response '200', 'Pobiera wyniki głosowania dla dzielnicy' do
        schema type: :object,
               properties: {
                 regionId: { type: :integer },
                 regionName: { type: :string },
                 budget: { type: :number, format: :float },
                 winCost: { type: :number, format: :float },
                 cardsAccepted: { type: :integer },
                 projects: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       number: { type: :integer },
                       title: { type: :string },
                       status: { type: :integer },
                       localization: { type: :string },
                       cost: { type: :number, format: :float },
                       costOfOperation: { type: :number, format: :float },
                       win: { type: :integer },
                       isValidPercentage: { type: :integer },
                       validPercent: { type: :number, format: :float },
                       cardsAccepted: { type: :integer },
                       votesAccepted: { type: :integer },
                       rejectTime: { type: :string }
                     }
                   }
                 }
               },
               required: %w[id parentId name]

        let(:id) { Blog.create(title: 'foo', content: 'bar').id }
        run_test!
      end

    end
  end
end

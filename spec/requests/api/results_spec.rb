require 'swagger_helper'

RSpec.describe 'api/results', type: :request do

  # path '/rest-api/results' do
  path '/rest-api-no-auth/results' do

    get 'Umożliwia pobranie listy dzielnic dla danej edycji' do
      tags 'Results'
      description 'Umożliwia pobieranie dzielnic dla edycji'
      produces 'application/json'
      parameter name: :groupId, in: :query, type: :integer, required: true
      request_body_example value: { groupId: '2022' }, name: 'basic', summary: 'Request example description'

      response '200', 'Lista dzielnic dla edycji' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   parentId: { type: :integer },
                   name: { type: :string },
                   budget: { type: :number, format: :float },
                   votingBudget: { type: :string, format: :decimal }
                 },
                 required: %w[id parentId name]
               }

        let(:id) { Blog.create(title: 'foo', content: 'bar').id }
        run_test!
      end

    end
  end
end

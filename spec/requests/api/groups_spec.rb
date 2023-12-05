require 'swagger_helper'

RSpec.describe 'api/groups', type: :request do

  # path '/rest-api/groups' do
  path '/rest-api-no-auth/groups' do

    get 'Umożliwia pobieranie informacji o edycjach budżetu' do
      tags 'Groups'
      description 'Umożliwia pobieranie informacji o edycjach budżetu'
      produces 'application/json'
      # request_body_example value: { groupId: '2022' }, name: 'basic', summary: 'Request example description'

      response '200', 'Lista edycji budżetu' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   name: { type: :string },
                   votingStart: { type: :string, format: :datetime },
                   votingEnd: { type: :string, format: :datetime }
                 },
                 required: %w[id name votingStart votingEnd]
               }

        # let(:id) { Blog.create(title: 'foo', content: 'bar').id }
        run_test!
      end

    end
  end
end

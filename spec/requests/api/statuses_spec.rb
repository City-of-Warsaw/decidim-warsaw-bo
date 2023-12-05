require 'swagger_helper'

RSpec.describe 'api/statuses', type: :request do

  # path '/rest-api/status' do
  path '/rest-api-no-auth/status' do

    get 'Pobieranie informacji o obecnie trwającej edycji' do
      tags 'Status'
      produces 'application/json'
      # parameter name: :id, in: :path, type: :string
      # request_body_example value: { some_field: 'Foo' }, name: 'basic', summary: 'Request example description'

      response '200', 'Informacje o obecnie trwającej edycji' do
        schema type: :object,
               properties: {
                 description: { type: :string },
                 status: { type: :string },
                 projectsInExecution: { type: :string }
               },
               required: %w[id title content]

        # let(:id) { Blog.create(title: 'foo', content: 'bar').id }
        run_test!
      end

    end
  end
end

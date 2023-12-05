require 'swagger_helper'

RSpec.describe 'api/map', type: :request do

  # path '/rest-api/map' do
  path '/rest-api-no-auth/map' do

    get 'Umożliwia pobranie zwycięskich projektów złożonych dla danego obszaru' do
      tags 'Map'
      description 'Umożliwia pobranie zwycięskich projektów złożonych dla danego obszaru'
      produces 'application/json'
      parameter name: :southWestLongitude, in: :query, type: :string
      parameter name: :southWestLatitude, in: :query, type: :string
      parameter name: :northEastLongitude, in: :query, type: :string
      parameter name: :northEastLatitude, in: :query, type: :string
      parameter name: :status, in: :query, type: :integer
      # request_body_example value: { some_field: 'Foo' }, name: 'basic', summary: 'Request example description'

      response '200', 'Lista projektow' do
        schema type: :array,
               properties: {
                 id: { type: :integer },
                 title: { type: :string },
                 lat: { type: :string },
                 lng: { type: :string },
                 progress: { type: :integer },
               },
               required: %w[id isPaper title]

        # let(:id) { Blog.create(title: 'foo', content: 'bar').id }
        run_test!
      end

    end

  end
end

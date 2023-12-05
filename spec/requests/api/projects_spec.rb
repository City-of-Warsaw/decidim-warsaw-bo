require 'swagger_helper'

RSpec.describe 'api/projects', type: :request do

  # path '/rest-api/projects' do
  path '/rest-api-no-auth/projects' do

    get 'Umożliwia pobieranie listy projektów' do
      tags 'Projects'
      description 'Umożliwia pobieranie listy projektów'
      produces 'application/json'
      parameter name: :groupId, in: :query, type: :integer, required: true
      parameter name: :limit, in: :query, type: :integer
      parameter name: :offset, in: :query, type: :integer
      # request_body_example value: { some_field: 'Foo' }, name: 'basic', summary: 'Request example description'

      response '200', 'Lista projektow' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       isPaper: { type: :integer },
                       title: { type: :string },
                       status: { type: :integer },
                       mainRegionName: { type: :string },
                       regionName: { type: :string },
                       number: { type: :integer }
                     }
                   }
                 },

                 total: { type: :integer },
                 limit: { type: :integer },
                 offset: { type: :integer }
               },
               required: %w[id isPaper title]

        # let(:id) { Blog.create(title: 'foo', content: 'bar').id }
        run_test!
      end

    end

    # path '/rest-api/projectDetails' do
    path '/rest-api-no-auth/projectDetails' do

      get 'Umożliwia pobieranie szczegółowych informacji o projekcie' do
        tags 'ProjectDetails'
        description 'Umożliwia pobieranie szczegółowych informacji o projekcie'
        produces 'application/json'
        parameter name: :id, in: :query, type: :integer, required: true

        # request_body_example value: { some_field: 'Foo' }, name: 'basic', summary: 'Request example description'

        response '200', 'Lista projektow' do
          schema type: :object,
                 properties: {
                   id: { type: :integer },
                   number: { type: :integer },
                   title: { type: :string },
                   status: { type: :integer },
                   description: { type: :string },
                   shortDescription: { type: :string },
                   submitted: { type: :string },
                   firstName: { type: :string },
                   lastName: { type: :string },
                   lat: { type: :string },
                   lng: { type: :string },
                   classifications: {
                     type: :array
                   },
                   created: { type: :string },
                   recipients: { type: :string },
                   taskLevel: { type: :string },
                   localization: { type: :string },
                   localizationExtra: { type: :string },
                   pins: {
                     type: :array,
                     items: {
                       type: :object,
                       properties: {
                         id: { type: :string },
                         lat: { type: :string },
                         lng: { type: :string },
                       }
                     }
                   },
                   availabilityDescription: { type: :string },
                   argumentation: { type: :string },
                   costSummary: { type: :string },
                   universalDesign: { type: :string },
                   universalDesignArgumentation: { type: :string },
                   cost: { type: :number, format: :float },
                   mainRegionName: { type: :string },
                   history: { type: :string },
                   cocreators: {
                     type: :array,
                     items: {
                       type: :object,
                       properties: {
                         firstName: { type: :string },
                         lastName: { type: :string },
                         name: { type: :string },
                       }
                     }
                   },
                   attachments: {
                     type: :array,
                     items: {
                       type: :object,
                       properties: {
                         url: { type: :string },
                         originalName: { type: :string }
                       }
                     }
                   },
                   url: { type: :string },
                   verification: {
                     type: :object,
                     properties: {
                       resultNotes: { type: :string },
                       attachments: {
                         type: :array,
                         items: {
                           type: :object,
                           properties: {
                             url: { type: :string },
                             originalName: { type: :string }
                           }
                         }
                       }
                     }
                   },
                   votes: { type: :integer },
                   comments: {
                     type: :array,
                     items: {
                       type: :object,
                       properties: {
                         login: { type: :string },
                         createTime: { type: :string },
                         text: { type: :string }
                       }
                     }
                   }
                 },
                 required: [ 'id', 'number', 'title' ]

          # let(:id) { Blog.create(title: 'foo', content: 'bar').id }
          run_test!
        end


      end
    end
  end
end

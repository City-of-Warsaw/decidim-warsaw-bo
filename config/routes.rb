Rails.application.routes.draw do
  # Swagger docs for REST API
  unless Rails.env.production?
    mount Rswag::Ui::Engine => '/api-docs'
    mount Rswag::Api::Engine => '/api-docs'
  end

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  require 'sidekiq/web'

  authenticate :user, lambda { |u| u.ad_admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  # blokada przegladania procesow
  get '/processes/:slug', to: redirect('/projects')

  # redirect from old project URLS to new schema
  get 'projekt/:id', to: 'expired_urls#redirect_to_project'

  mount Decidim::Core::Engine => '/'

end

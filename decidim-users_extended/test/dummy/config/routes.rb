Rails.application.routes.draw do
  mount Decidim::UsersExtended::Engine => "/decidim-users_extended"
end

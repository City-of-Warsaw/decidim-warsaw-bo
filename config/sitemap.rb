# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://bo.um.warszawa.pl"
SitemapGenerator::Sitemap.compress = false

SitemapGenerator::Sitemap.create do
  add Decidim::Projects::Engine.routes.url_helpers.projects_lists_path
  add Decidim::Projects::Engine.routes.url_helpers.realizations_path
  add 'pages/terms-and-conditions'
  add 'pages/o-budzecie'
  add 'pages/ile-kosztuje-miasto'
  add 'pages/zglaszanie-pomyslow12321'
  add 'pages/statistics'
  add 'pages/koordynatorzy-w-dzielnicach'
  add 'pages/deklaracja-dostepnosci'
  add 'pages/klauzula-informacyjna'
  Decidim::Projects::Project.published.find_each do |project|
    add Decidim::ResourceLocatorPresenter.new(project).path, :changefreq => 'daily'
  end
end

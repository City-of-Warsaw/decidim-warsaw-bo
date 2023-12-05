# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron
#
every 1.day, at: '0:30 am' do
  rake "rake user_check_ad_access"
end

every 1.week, at: '1:30 am' do
  rake "rake sitemap:refresh"
end


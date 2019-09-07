source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

gem 'clearance'
gem 'creek'
gem 'faker'
gem 'fog'
gem 'gon'
gem 'jbuilder', '~> 2.5'
gem 'kaminari'
gem 'pdfkit'
gem 'pg'
gem 'puma', '~> 3.11'
gem 'rails', '~> 5.2.0'
gem 'render_anywhere'
gem 'sass-rails', '~> 5.0'
gem 'slim'
gem 'uglifier', '>= 1.3.0'
gem 'webpacker', '~> 3.5'
gem 'wicked_pdf', '~> 1.1'
gem 'wkhtmltopdf-heroku'
gem 'administrate'
gem 'brakeman'
gem 'carrierwave'
gem 'roo', '~> 2.8.0'
gem 'rails_12factor', group: :production
gem 'public_activity'
gem 'usagewatch'
# gem 'chartkick'
# gem 'savon', '~> 2.12.0'
gem 'activity_notification'
gem 'pgsync'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'capybara-webkit'
  gem 'factory_bot_rails'
  gem 'pry'
  gem 'pry-nav'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :development do
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'database_cleaner'
  gem 'rspec_junit_formatter', git: 'http://github.com/sj26/rspec_junit_formatter'
  gem 'simplecov', require: false
  gem 'webmock'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require 'simplecov'
SimpleCov.start do
  add_filter "/spec"
end

require 'versioneye-security'
require 'rspec/autorun'
require 'mongoid'
require 'database_cleaner'
require 'rubygems'
require 'bundler'

require 'versioneye-core'

require 'versioneye/domain_factories/product_factory'
require 'versioneye/domain_factories/user_factory'

Mongoid.load!("config/mongoid.yml", :test)
Mongoid.logger.level = Logger::ERROR
Moped.logger.level   = Logger::ERROR

RSpec.configure do |config|

  VersioneyeSecurity.new

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.orm = "mongoid"
  end

  config.before(:each) do
    DatabaseCleaner.clean
  end

end

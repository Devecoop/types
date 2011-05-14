ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Webmock stubbing
require 'webmock'
include WebMock::API

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # Mock library
  config.mock_with :rspec

  # Cleaning up MongoDB after specs have ben executed
  config.after :suite do
    Mongoid.master.collections.select do |collection|
      collection.name !~ /system/
    end.each(&:drop)
  end

  # Clean user definition after every test
  config.after :each do
    User.destroy_all
  end
end

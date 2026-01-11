ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require_relative 'spec_helper'

RSpec.configure do |config|
  config.include Rails.application.routes.url_helpers
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end

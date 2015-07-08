$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'tm_checkout'
require 'pry'

RSpec.configure do |config|
  config.filter_run_excluding filter: true
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
end
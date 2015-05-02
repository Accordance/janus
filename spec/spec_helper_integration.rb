require_relative 'spec_helper'

RSpec.configure do |config|
  config.include Mongoid::Matchers, type: :model
  config.before :each do
    Mongoid.purge!
  end
end

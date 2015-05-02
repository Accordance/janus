ENV['RACK_ENV'] = 'testing'
RACK_ENV = ENV['RACK_ENV']

require 'bundler'
Bundler.require(:default, :test)

Dir[File.dirname(__FILE__) + '/../config/initializers/*.rb'].sort.each { |file| require file }

$LOAD_PATH << File.expand_path('../../lib', __FILE__)
$LOAD_PATH << File.expand_path('../../daemons', __FILE__)
$LOAD_PATH << File.expand_path('../../server/lib', __FILE__)
$LOAD_PATH << File.expand_path('../../config/initializers', __FILE__)

require 'sidekiq/testing'
require 'simplecov'
require 'rspec'
require 'rack/test'
require 'tmpdir'
require 'vcr'
require 'json'

SimpleCov.start do
  add_filter 'spec'
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :webmock # or :fakeweb
  config.default_cassette_options = {
    match_requests_on: [:uri, :body, :method],
    record: :new_episodes
  }
  config.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.filter_run_excluding broken: true

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.mock_with :rspec
  # config.expect_with :rspec
  config.include Rack::Test::Methods
end

RSpec::Matchers.define :be_json do |string|
  match do |data|
    hash = JSON.parse(data)
    expect(hash).to be_eql(string)
  end
end

def fixture_dir
  File.expand_path '../fixtures', __FILE__
end

def fixture(file)
  File.join fixture_dir, file
end

require 'spec_helper'
require_relative '../../lib/version'

describe 'Misc' do
  it 'returns name' do
    expect(Application::NAME).to be == 'janus'
  end
end

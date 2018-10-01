require 'spec_helper'
require 'puppet/type/test_something'

RSpec.describe 'the test_something type' do
  it 'loads' do
    expect(Puppet::Type.type(:test_something)).not_to be_nil
  end
end

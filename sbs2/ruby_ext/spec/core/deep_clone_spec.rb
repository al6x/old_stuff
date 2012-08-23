require "spec_helper"

describe 'deep_clone' do
  after{remove_constants :Metadata}

  it "basic" do
    hash, array = {}, ['value']
    hash['key'] = array

    hash2 = hash.deep_clone
    array2 = hash2['key']

    hash2.should == hash
    hash2.object_id.should_not == hash.object_id

    array2.should == array
    array2.object_id.should_not == array.object_id
  end

  it 'cloning object tree' do
    class Metadata
      attr_accessor :registry

      def initialize
        @registry = {}
      end
    end

    m = Metadata.new
    m.registry[:a] = 1

    m2 = m.deep_clone
    m2.registry.should include(:a)
    m2.registry[:b] = 2

    m.registry.should == {a: 1}
  end
end
RSpec.shared_examples 'a noop canonicalizer' do
  context 'canonicalize is called' do
    let(:resources) do
      {
        name:   'foo',
        ensure: 'present',
        foo:    'bar',
      }
    end
    let(:provider) { described_class.new }

    it 'returns the same resource' do
      expect(provider.canonicalize(anything, resources)[:name].object_id).to eq(resources[:name].object_id)
      expect(provider.canonicalize(anything, resources)[:ensure].object_id).to eq(resources[:ensure].object_id)
      expect(provider.canonicalize(anything, resources)[:foo].object_id).to eq(resources[:foo].object_id)
    end

    it 'returns unmodified resource' do
      expect(provider.canonicalize(anything, resources)).to eq(name: 'foo', ensure: 'present', foo: 'bar')
    end
  end
end

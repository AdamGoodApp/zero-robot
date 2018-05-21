describe CacheJob, type: :job do
  make_private_public(described_class)

  subject { described_class.new }

  it 'is in the cache queue' do
    expect(described_class.new.queue_name).to eq('cache')
  end

  describe '.perform' do
    context 'when nothing changed' do
      it 'does not update' do
        message = {a: 1}
        cache = {}
        expect(described_class).to receive(:read_cache!).with(no_args).and_return(cache)
        expect(subject).not_to receive(:update_cache!)
        expect(subject).to receive(:merge_cache!).once.with(cache, message).and_return(false)

        messages = [message]
        subject.perform(messages)
      end
    end

    context 'when something changed' do
      it 'updates' do
        message = {a: 1}
        cache = {}
        expect(described_class).to receive(:read_cache!).with(no_args).and_return(cache)
        expect(subject).to receive(:update_cache!).once.with(cache)
        expect(subject).to receive(:merge_cache!).once.with(cache, message).and_return(true)

        messages = [message]
        subject.perform(messages)
      end
    end
  end

  describe 'self.read_cache!' do
    context 'when it is not empty' do
      let (:cache_json) { '{"a": 2, "b": 3}' }
      let (:cache) { {'a' => 2, 'b' => 3} }

      it 'returns the cache' do
        expect($cache).to receive(:read).with('robot_cache').and_return(cache_json)

        result = described_class.read_cache!
        expect(result).to eq(cache)
      end
    end

    context 'when it is empty' do
      it 'returns an empty hash' do
        expect($cache).to receive(:read).with('robot_cache').and_return(nil)

        result = described_class.read_cache!
        expect(result).to eq({})
      end
    end
  end

  describe '.update_cache!' do
    it 'writes to the global cache' do
      json = '123'
      cache = double('cache', to_json: json)
      expect($cache).to receive(:write).with('robot_cache', json)
      subject.update_cache!(cache)
    end
  end
end

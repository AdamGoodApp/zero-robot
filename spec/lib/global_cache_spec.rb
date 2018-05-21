require "fakeredis"

def create_with_config(&get_config)
  allow_any_instance_of(GlobalCache).to receive(:get_config) { get_config.call }
  GlobalCache.new
end

describe GlobalCache do

  describe '.initialize' do
    it 'creates a Redis adapter' do
      cache = create_with_config { {"adapter" => "redis"} }
      expect(cache.instance_variable_get(:@adapter)).to be_a(GlobalCache::RedisAdapter)
    end

    it 'creates a Memory adapter' do
      cache = create_with_config { {"adapter" => "memory"} }
      expect(cache.instance_variable_get(:@adapter)).to be_a(GlobalCache::MemoryAdapter)
    end

    it 'fallbacks on a Memory adapter with no file' do
      cache = create_with_config { raise "failed to find file" }
      expect(cache.instance_variable_get(:@adapter)).to be_a(GlobalCache::MemoryAdapter)
    end

    it 'fails with a missing `adapter` entry' do
      expect { create_with_config { {"adapter2" => "memory"} } }.to raise_error(ArgumentError, 'GlobalCache: Missing `adapter` value')
    end

    it 'fails with an invalid `adapter` entry' do
      expect { create_with_config { {"adapter" => "memory2"} } }.to raise_error(ArgumentError, 'GlobalCache: Invalid `adapter` value (must be `memory` or `redis`)')
    end
  end

  describe 'MemoryAdapter' do

    context 'when using mutex' do
      let (:cache) { create_with_config { {"adapter" => "memory", "synchronize" => false} } }

      it 'reads and writes' do
        cache.write('hello', :world)
        expect(cache.read('hello')).to be(:world)
      end

      it 'answers with nil if it the key doesn\'t exist' do
        expect(cache.read('hello2')).to be(nil)
      end
    end

    context 'when using mutex' do
      let (:cache) { create_with_config { {"adapter" => "memory"} } }

      it 'reads and writes' do
        cache.write('hello', :world)
        expect(cache.read('hello')).to be(:world)
      end

      it 'answers with nil if it the key doesn\'t exist' do
        expect(cache.read('hello2')).to be(nil)
      end

      it 'supports multi-threading' do
        cache.write('order', -1)

        threads = []

        10.times do |i|
          threads[i] = Thread.new do
            Thread.current['secret'] = secret = rand(0)
            cache.write("Thread#{i}", secret)
            sleep(rand(0) / 10.0)
            Thread.current['order'] = cache.read('order')
            cache.write('order', i)
          end
        end

        threads.each_with_index do |t, i|
          t.join
          expect(cache.read("Thread#{i}")).to be(t['secret'])
        end

        expect(cache.read('order')).not_to be(-1)
      end
    end
  end

  describe 'RedisAdapter' do
    let (:cache) { create_with_config { {"adapter" => "redis"} } }

    it 'reads and writes' do
      cache.write('hello', 'world')
      expect(cache.read('hello')).to eq('world')
    end

    it 'answers with nil if it the key doesn\'t exist' do
      expect(cache.read('hello2')).to be(nil)
    end
  end

end

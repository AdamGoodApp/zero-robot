require 'redis'
require 'active_support/core_ext/module/delegation'

class GlobalCache
  delegate :read, :write, to: :@adapter

  def initialize
    begin
      config = get_config
    rescue
      config = {'adapter' => 'memory'}
    end
    @adapter = create_adapter(config)
  end

  private

  def get_config
    Rails.application.config_for(:global_cache)
  end

  def create_adapter(config)
    if config['adapter'] == 'redis'
      return RedisAdapter.new(config)
    elsif config['adapter'] == 'memory'
      return MemoryAdapter.new(config)
    elsif config.key?('adapter')
      raise ArgumentError, 'GlobalCache: Invalid `adapter` value (must be `memory` or `redis`)'
    end
    raise ArgumentError, 'GlobalCache: Missing `adapter` value'
  end

  class RedisAdapter
    def initialize(config)
      @redis = Redis.new(config)
    end

    def read(key)
      @redis.hget("global_cache", key)
    end

    def write(key, value)
      @redis.hset("global_cache", key, value)
    end
  end

  class MemoryAdapter
    def initialize(config)
      @hash = {}
      @mutex = Mutex.new
      @sync = config.key?('synchronize') ? config['synchronize'] : true
    end

    def read(key)
      synchronize { @hash[key] }
    end

    def write(key, value)
      synchronize { @hash[key] = value }
    end

    private

    def synchronize(&block)
      if @sync
        @mutex.synchronize { block.call }
      else
        block.call
      end
    end

  end

end

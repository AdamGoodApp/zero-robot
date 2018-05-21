class CacheJob < MergeJob
  queue_as :cache

  def perform(messages)
    cache = self.class.read_cache!
    changed = false
    messages.each do | message, _ |
      result = merge_cache!(cache, message)
      changed = changed || result
    end
    update_cache!(cache) if changed
  end

  def self.read_cache!
    cache = $cache.read('robot_cache')
    cache.nil? ? {} : JSON.parse(cache)
  end

  private

  def update_cache!(cache)
    $cache.write('robot_cache', cache.to_json)
  end

end

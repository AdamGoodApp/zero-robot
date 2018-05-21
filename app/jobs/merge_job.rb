class MergeJob < ApplicationJob

  def self.adapt_servos(data)
    data = data.with_indifferent_access
    if data.key?(:servo_data)
      servo = data[:servo_data]
      servoId = servo[:servo_id]
      data[:servo_data] = default_servos
      data[:servo_data][servoId] = servo
    end
    data
  end

  private

  def self.default_servos
    [{}, {}, {}, {}, {}, {}, {}]
  end

  def merge_message!(dest, source)
    recursive_merge!(dest, source)
  end

  def merge_cache!(dest, source)
    recursive_merge!(dest, source, messages: 1000, strip_cache: true, string_key: true)
  end

  def recursive_merge!(dest, source, messages: nil, strip_cache: false, string_key: false)
    should_change = false

    if strip_cache
      source.select! do |source_key, v|
        k = source_key.to_sym
        k != :sdo && k != :timeline && k != :jog && k != :pid_tuning && k != :action && k != :bd_waypoint
      end
    end
    source.each do |source_key2, value|
      source_key = source_key2.to_sym
      key = string_key ? source_key.to_s : source_key

      if source_key == :message or source_key == :bd_waypoint
        dest[key] = [] unless dest.key?(key)
        if value.is_a?(Array)
          dest[key].concat(value)
        else
          dest[key] << value
        end
        if source_key == :message and (not messages.nil?) and dest[key].length > messages
          dest[key].slice!(0...(dest[key].length - messages))
        end
        should_change = true

      elsif source_key == :servo_data
        dest[key] = self.class.default_servos unless dest.key?(key)

        value.each_with_index do |v,i|
          unless value[i].nil?
            should_change = true if recursive_merge!(dest[key][i], value[i], messages: messages, strip_cache: strip_cache, string_key: string_key)
          end
        end

      elsif (dest.key?(key) and dest[key] != value) or (not dest.key?(key))
        if value.is_a?(Hash)
          dest[key] = {} unless dest.key?(key)
          should_change = true if recursive_merge!(dest[key], value, messages: messages, strip_cache: strip_cache, string_key: string_key)
        else
          dest[key] = value
          should_change = true
        end

      end
    end

    should_change
  end

end

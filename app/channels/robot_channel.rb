class RobotChannel < ApplicationCable::Channel
  require 'protocol/eva_pb'

  def subscribed
    stop_all_streams
    stream_for current_user # Channel associated with a user
    stream_from "robot_#{current_user.role}" # Channel associated with user role
    stream_from 'robot' # Global channel identifier
  end

  def message(data)
    if filter_recv(data)
      ZeroMQ.send self.class.serialize_message(data)
      data = MergeJob.adapt_servos(data)
      RobotChannel.broadcast_message(data)
      CacheJob.perform_later(data)
    end
  end

  private

  def self.new_toolpath(user, info)
    RobotChannel.broadcast_to(user, info.merge(_action: 'new_toolpath'))
  end

  def self.updated_toolpath(user, info)
    RobotChannel.broadcast_to(user, info.merge(_action: 'updated_toolpath'))
  end

  def self.deleted_toolpath(user, info)
    RobotChannel.broadcast_to(user, info.merge(_action: 'deleted_toolpath'))
  end

  def self.shared_toolpath(user, info)
    RobotChannel.broadcast_to(user, info.merge(_action: 'shared_toolpath'))
  end

  def self.new_user(info)
    ActionCable.server.broadcast('robot', info.merge(_action: 'new_user'))
  end

  def self.updated_user(info)
    ActionCable.server.broadcast('robot', info.merge(_action: 'updated_user'))
  end

  def self.deleted_user(info)
    ActionCable.server.broadcast('robot', info.merge(_action: 'deleted_user'))
  end

  def self.broadcast_message(message)
    ActionCable.server.broadcast('robot_admin', message)
    filtered_msg = RobotChannel.filter_send(message)
    if !filtered_msg.empty?
      ActionCable.server.broadcast('robot_client', filtered_msg)
    end
  end

  def filter_recv(message)
    message = message.with_indifferent_access
    if current_user.role == 'admin'
      # Control, SDO, Global, Servo
      if [2, 3, 4, 5].include?(message[:type])
        return true
      end
    else
      # Control
      if message[:type] == 2 and !message[:control].nil?
        # Play, Pause, Home, Stop, Upload, Scheduler, Reset errors
        if [0, 1, 2, 3, 4, 5, 11].include?(message[:control][:type])
          return true
        end
      end
    end
    return false
  end

  def self.filter_send(message)
    message = message.with_indifferent_access
    message.reject! do | k, _ |
      k == "type" or k == "logging" or k == "sdo" or k == "global_data" or k == "servo_data" or k == "e_internal" or k == "bd_waypoint"
    end
    if !message[:control].nil?
      message[:control].reject! do | k, _ |
        k == "type" or k == "jog" or k == "pid_tuning"
      end
      if message[:control].empty?
        message.delete(:control)
      end
    end
    return message
  end

  def self.serialize_message(data)
    serialize_elements(Eva::Message.new, data.delete_if { |key,value| key == 'action' })
  end

  def self.serialize_elements(message, elements)
    elements.each do | key, value |
      if value.is_a?(Array)
        value.each do | rvalue |
          message[key] << serialize_elements(new_message_for_attribute(message, key), rvalue)
        end
      else
        message[key] =
          if value.is_a?(Hash)
            serialize_elements(new_message_for_attribute(message, key), value)
          else
            serialize_literal(value, message, key)
          end
        end
    end
    message
  end

  def self.serialize_literal(value, message, key)
    field = message[key]
    if field.is_a?(NilClass)
      wrapper = new_message_for_attribute(message, key)
      wrapper.value = serialize_literal(value, wrapper, 'value')
      wrapper
    elsif field.is_a?(Fixnum) or field.is_a?(Symbol)
      value.to_i
    elsif field.is_a?(Float)
      value.to_f
    elsif field.is_a?(FalseClass)
      if value.is_a?(TrueClass) or value.is_a?(FalseClass)
        value
      elsif value.is_a?(Fixnum)
        !value.zero?
      else
        value == 'true'
      end
    else
      value
    end
  end

  def self.new_message_for_attribute(parent, attribute)
    message = parent.class.descriptor.lookup(attribute)
    if message.nil?
      raise ArgumentError, "Cannot find '#{attribute}' in #{parent}"
    end
    Google::Protobuf::DescriptorPool.generated_pool.lookup(message.submsg_name).msgclass.new
  end

end

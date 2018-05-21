# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: eva.proto

require 'google/protobuf'

require_relative 'dashboard_pb'
require_relative 'servos_pb'
require_relative 'internal_pb'
require_relative 'utils_pb'
Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "eva.Message" do
    optional :type, :enum, 1, "eva.Message.MessageType"
    oneof :message_object do
      optional :logging, :message, 2, "eva.Logging"
      optional :dashboard, :message, 3, "eva.Dashboard"
      optional :control, :message, 4, "eva.Control"
      optional :sdo, :message, 5, "eva.SDO"
      optional :global_data, :message, 6, "eva.Global"
      optional :servo_data, :message, 7, "eva.Servo"
      optional :e_internal, :message, 8, "eva.Internal"
      optional :bd_waypoint, :message, 9, "eva.Angles"
    end
  end
  add_enum "eva.Message.MessageType" do
    value :LOGGING, 0
    value :DASHBOARD, 1
    value :CONTROL, 2
    value :SDO, 3
    value :GLOBAL_DATA, 4
    value :SERVO_DATA, 5
    value :E_INTERNAL, 6
    value :BD_WAYPOINT, 7
  end
  add_message "eva.Logging" do
    optional :message, :string, 1
  end
end

module Eva
  Message = Google::Protobuf::DescriptorPool.generated_pool.lookup("eva.Message").msgclass
  Message::MessageType = Google::Protobuf::DescriptorPool.generated_pool.lookup("eva.Message.MessageType").enummodule
  Logging = Google::Protobuf::DescriptorPool.generated_pool.lookup("eva.Logging").msgclass
end

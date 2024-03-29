# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: dashboard.proto

require 'google/protobuf'

require_relative 'timeline_pb'
require_relative 'utils_pb'
require_relative 'google/protobuf/wrappers_pb'
Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "eva.Dashboard" do
    optional :loop_count, :message, 1, "google.protobuf.UInt32Value"
    optional :loop_target, :message, 2, "google.protobuf.UInt32Value"
    optional :status, :message, 3, "google.protobuf.StringValue"
    optional :estop_active, :message, 4, "google.protobuf.BoolValue"
    optional :robotState, :enum, 5, "eva.Dashboard.RobotState"
  end
  add_enum "eva.Dashboard.RobotState" do
    value :NONE, 0
    value :READY, 1
    value :ERROR, 2
    value :RUNNING, 3
    value :PAUSED, 4
    value :STOPPING, 5
    value :JOGGING, 6
    value :BACKDRIVING, 7
  end
  add_message "eva.Control" do
    optional :type, :enum, 1, "eva.Control.ControlType"
    oneof :control_object do
      optional :number_of_loops, :message, 2, "google.protobuf.UInt32Value"
      optional :timeline, :message, 3, "eva.Timeline"
      optional :scheduler, :message, 4, "eva.Scheduler"
      optional :jog, :message, 5, "eva.Angles"
      optional :pid_tuning, :message, 6, "eva.PIDTuning"
      optional :waypoint, :message, 7, "eva.Angles"
    end
  end
  add_enum "eva.Control.ControlType" do
    value :PLAY, 0
    value :PAUSE, 1
    value :HOME, 2
    value :STOP, 3
    value :UPLOAD, 4
    value :SCHEDULER, 5
    value :JOG_START, 6
    value :JOG, 7
    value :JOG_END, 8
    value :PID_TUNE, 9
    value :GO_TO, 10
    value :RESET_ERRORS, 11
  end
  add_message "eva.PIDTuning" do
    optional :a0, :float, 1
    optional :a1, :float, 2
    optional :a2, :float, 3
    optional :a3, :float, 4
    optional :a4, :float, 5
    optional :a5, :float, 6
    optional :a6, :float, 7
    optional :timestep, :float, 8
    optional :duration, :float, 9
  end
  add_message "eva.Scheduler" do
    optional :enabled, :bool, 1
    optional :start_time, :message, 2, "google.protobuf.UInt32Value"
    optional :stop_time, :message, 3, "google.protobuf.UInt32Value"
  end
end

module Eva
  Dashboard = Google::Protobuf::DescriptorPool.generated_pool.lookup("eva.Dashboard").msgclass
  Dashboard::RobotState = Google::Protobuf::DescriptorPool.generated_pool.lookup("eva.Dashboard.RobotState").enummodule
  Control = Google::Protobuf::DescriptorPool.generated_pool.lookup("eva.Control").msgclass
  Control::ControlType = Google::Protobuf::DescriptorPool.generated_pool.lookup("eva.Control.ControlType").enummodule
  PIDTuning = Google::Protobuf::DescriptorPool.generated_pool.lookup("eva.PIDTuning").msgclass
  Scheduler = Google::Protobuf::DescriptorPool.generated_pool.lookup("eva.Scheduler").msgclass
end

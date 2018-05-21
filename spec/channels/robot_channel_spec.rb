def assign_channel(clazz)
  setup_request
  setup_connection
  fetch_robot
  create_user

  make_protected_public(clazz)
  subject {
    allow_any_instance_of(clazz).to receive(:subscribed)
    channel = clazz.new(connection, "test-channel", {:robot => robot.id})
    allow(channel).to receive(:current_user).and_return(user)
    channel
  }
end

require 'protocol/eva_pb'

describe RobotChannel, type: :channel do
  assign_channel(described_class)

  describe '.subscribed' do
    it 'starts streaming the robot channel' do
      allow(subject).to receive(:subscribed).and_call_original
      expect(subject).to receive(:stop_all_streams).with(no_args)
      expect(subject).to receive(:stream_from).with('robot').once
      expect(subject).to receive(:stream_from).with('robot_admin').once
      expect(subject).to receive(:stream_for).with(user).once
      subject.subscribed
    end

    it 'starts streaming the robot channel (non admin)' do
      user.role = 'client'
      allow(subject).to receive(:subscribed).and_call_original
      expect(subject).to receive(:stop_all_streams).with(no_args)
      expect(subject).to receive(:stream_from).with('robot').once
      expect(subject).to receive(:stream_from).with('robot_client').once
      expect(subject).to receive(:stream_for).with(user).once
      subject.subscribed
    end
  end

  describe '.message' do
    it 'broadcasts and enqueue a cache job' do
      allow(subject).to receive(:subscribed).and_call_original
      subject.subscribed

      param = {a: 1, b: 42}
      param2 = {a: [1], b: [42]}
      serializedParam = 'a+1, b+42'

      expect(RobotChannel).to receive(:serialize_message).once.with(param).and_return(serializedParam)
      expect(ZeroMQ).to receive(:send).once.with(serializedParam)
      expect(MergeJob).to receive(:adapt_servos).once.with(param).and_return(param2)
      expect(RobotChannel).to receive(:broadcast_message).once.with(param2)
      expect(CacheJob).to receive(:perform_later).once.with(param2)

      subject.message(param)
    end
  end

  describe 'self.new_toolpath' do
    it 'forwards the notification' do
      user = {hello: 'a'}
      expect(RobotChannel).to receive(:broadcast_to).once.with(user, {_action: 'new_toolpath', secret: 42})
      RobotChannel.new_toolpath(user, {secret: 42})
    end
  end

  describe 'self.updated_toolpath' do
    it 'forwards the notification' do
      user = {hello: 'a'}
      expect(RobotChannel).to receive(:broadcast_to).once.with(user, {_action: 'updated_toolpath', secret: 42})
      RobotChannel.updated_toolpath(user, {secret: 42})
    end
  end

  describe 'self.deleted_toolpath' do
    it 'forwards the notification' do
      user = {hello: 'a'}
      expect(RobotChannel).to receive(:broadcast_to).once.with(user, {_action: 'deleted_toolpath', secret: 42})
      RobotChannel.deleted_toolpath(user, {secret: 42})
    end
  end

  describe 'self.shared_toolpath' do
    it 'forwards the notification' do
      user = {hello: 'a'}
      expect(RobotChannel).to receive(:broadcast_to).once.with(user, {_action: 'shared_toolpath', secret: 42})
      RobotChannel.shared_toolpath(user, {secret: 42})
    end
  end

  describe 'self.new_user' do
    it 'forwards the notification' do
      expect(ActionCable.server).to receive(:broadcast).once.with('robot', {_action: 'new_user', secret: 42})
      RobotChannel.new_user({secret: 42})
    end
  end

  describe 'self.updated_user' do
    it 'forwards the notification' do
      expect(ActionCable.server).to receive(:broadcast).once.with('robot', {_action: 'updated_user', secret: 42})
      RobotChannel.updated_user({secret: 42})
    end
  end

  describe 'self.deleted_user' do
    it 'forwards the notification' do
      expect(ActionCable.server).to receive(:broadcast).once.with('robot', {_action: 'deleted_user', secret: 42})
      RobotChannel.deleted_user({secret: 42})
    end
  end

  describe 'self.broadcast_message' do
    it 'sends different messages to different roles' do
      param1 = {a: 1, b: 42}
      param2 = {a: 1}
      expect(RobotChannel).to receive(:filter_send).with(param1).and_return(param2)

      expect(ActionCable.server).to receive(:broadcast).once.with('robot_admin', param1)
      expect(ActionCable.server).to receive(:broadcast).once.with('robot_client', param2)

      RobotChannel.broadcast_message(param1)
    end

    it 'sends nothing if the filtered message is empty' do
      param1 = {a: 1, b: 42}
      param2 = {}
      expect(RobotChannel).to receive(:filter_send).with(param1).and_return(param2)

      expect(ActionCable.server).to receive(:broadcast).once.with('robot_admin', param1)
      expect(ActionCable.server).not_to receive(:broadcast)

      RobotChannel.broadcast_message(param1)
    end
  end

  describe 'filter_recv' do
    make_pending('TODO')
  end

  describe 'self.filter_send' do
    make_pending('TODO')
  end

  describe 'self.serialize_message' do
    it 'serializes servo data' do
      data = {'type' => 5, 'servo_data' =>
        {'servo_id' => 42, 'telemetry' => {'current' => 43},
          'errors' => {'hardware_startup' => true, 'can_bus' => 0, 'motor_encoder' => 1, 'output_encoder' => 'true', 'drv8305' => 'gloubiboulga', 'board_temperature' => false}
      }, 'action' => 'bullshit'}
      expect(described_class).to receive(:serialize_elements).once.with(instance_of(Eva::Message), data).and_call_original
      expect(described_class).to receive(:serialize_elements).once.with(instance_of(Eva::Servo), data['servo_data']).and_call_original
      expect(described_class).to receive(:serialize_elements).once.with(instance_of(Eva::Telemetry), data['servo_data']['telemetry']).and_call_original
      expect(described_class).to receive(:serialize_elements).once.with(instance_of(Eva::Errors), data['servo_data']['errors']).and_call_original
      result = described_class.serialize_message(data)
      expect(result).to be_a(Eva::Message)
      expect(result.type).to be(:SERVO_DATA)
      expect(result.servo_data).to be_a(Eva::Servo)
      expect(result.servo_data.servo_id).to be(42)
      expect(result.servo_data.telemetry).to be_a(Eva::Telemetry)
      expect(result.servo_data.telemetry.current).to be_a(Google::Protobuf::UInt32Value)
      expect(result.servo_data.telemetry.current.value).to be(43)
      expect(result.servo_data.errors).to be_a(Eva::Errors)
      expect(result.servo_data.errors.hardware_startup).to be_a(Google::Protobuf::BoolValue)
      expect(result.servo_data.errors.hardware_startup.value).to be(true)
      expect(result.servo_data.errors.can_bus).to be_a(Google::Protobuf::BoolValue)
      expect(result.servo_data.errors.can_bus.value).to be(false)
      expect(result.servo_data.errors.motor_encoder).to be_a(Google::Protobuf::BoolValue)
      expect(result.servo_data.errors.motor_encoder.value).to be(true)
      expect(result.servo_data.errors.output_encoder).to be_a(Google::Protobuf::BoolValue)
      expect(result.servo_data.errors.output_encoder.value).to be(true)
      expect(result.servo_data.errors.drv8305).to be_a(Google::Protobuf::BoolValue)
      expect(result.servo_data.errors.drv8305.value).to be(false)
      expect(result.servo_data.errors.board_temperature).to be_a(Google::Protobuf::BoolValue)
      expect(result.servo_data.errors.board_temperature.value).to be(false)
    end

    it 'serializes a timeline' do
      data = {'type' => 2, 'control' =>
        {'type' => 4, 'timeline' =>
          {'speed' => 42.0, 'objects' => [
            {'type' => 0, 'waypoint' =>
              {'type' => 0, 'time' => 3, 'a0' => 1}
            },
            {'type' => 0, 'waypoint' =>
              {'type' => 0, 'a0' => 2}
            }
          ]}
        }
      }
      expect(described_class).to receive(:serialize_elements).once.with(instance_of(Eva::Message), data).and_call_original
      expect(described_class).to receive(:serialize_elements).once.with(instance_of(Eva::Control), data['control']).and_call_original
      expect(described_class).to receive(:serialize_elements).once.with(instance_of(Eva::Timeline), data['control']['timeline']).and_call_original
      expect(described_class).to receive(:serialize_elements).once.with(instance_of(Eva::TimelineObject), data['control']['timeline']['objects'][0]).and_call_original
      expect(described_class).to receive(:serialize_elements).once.with(instance_of(Eva::TimelineObject), data['control']['timeline']['objects'][1]).and_call_original
      expect(described_class).to receive(:serialize_elements).once.with(instance_of(Eva::Waypoint), data['control']['timeline']['objects'][0]['waypoint']).and_call_original
      expect(described_class).to receive(:serialize_elements).once.with(instance_of(Eva::Waypoint), data['control']['timeline']['objects'][1]['waypoint']).and_call_original
      result = described_class.serialize_message(data)
      expect(result).to be_a(Eva::Message)
      expect(result.type).to be(:CONTROL)
      expect(result.control).to be_a(Eva::Control)
      expect(result.control.type).to be(:UPLOAD)
      expect(result.control.timeline).to be_a(Eva::Timeline)
      expect(result.control.timeline.speed).to be(42.0)
      expect(result.control.timeline.objects).to be_a(Google::Protobuf::RepeatedField)
      expect(result.control.timeline.objects[0]).to be_a(Eva::TimelineObject)
      expect(result.control.timeline.objects[0].type).to be(:WAYPOINT)
      expect(result.control.timeline.objects[0].waypoint).to be_a(Eva::Waypoint)
      expect(result.control.timeline.objects[0].waypoint.type).to be(:LINEAR)
      expect(result.control.timeline.objects[0].waypoint.time).to be(3.0)
      expect(result.control.timeline.objects[0].waypoint.a0).to be(1.0)
      expect(result.control.timeline.objects[1]).to be_a(Eva::TimelineObject)
      expect(result.control.timeline.objects[1].type).to be(:WAYPOINT)
      expect(result.control.timeline.objects[1].waypoint).to be_a(Eva::Waypoint)
      expect(result.control.timeline.objects[1].waypoint.type).to be(:LINEAR)
      expect(result.control.timeline.objects[1].waypoint.a0).to be(2.0)
    end

    it 'serializes a logging message' do
      data = {'type' => 0, 'logging' => {'message' => 'ABC'}}
      result = described_class.serialize_message(data)
      expect(result).to be_a(Eva::Message)
      expect(result.type).to be(:LOGGING)
      expect(result.logging).to be_a(Eva::Logging)
      expect(result.logging.message).to eq('ABC')
    end
  end

  describe 'self.new_message_for_attribute' do
    it 'looks up the right class for a protobuf field' do
      result = described_class.new_message_for_attribute(Eva::Global.new, 'reset_all_errors')
      expect(result).to be_a(Google::Protobuf::BoolValue)
    end

    it 'raises an error if it cannot find it' do
      expect do
        described_class.new_message_for_attribute(Eva::Global.new, 'random')
      end.to raise_error(ArgumentError, /Cannot find 'random' in #<Eva::Global:.*>/)
    end
  end
end

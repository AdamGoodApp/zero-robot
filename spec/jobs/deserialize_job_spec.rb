describe DeserializeJob, type: :job do
  make_private_public(described_class)

  subject { described_class.new }

  it 'is in the deserialize queue' do
    expect(described_class.new.queue_name).to eq('deserialize')
  end

  it 'defines all the enums' do
    enums = described_class.class_variable_get :@@enums
    expect(enums.length).to be 8
    expect(enums[0]).to be Eva::SDO::ReadWrite
    expect(enums[1]).to be Eva::ServoConfiguration::ServoMode
    expect(enums[2]).to be Eva::ServoConfiguration::CommutationMode
    expect(enums[3]).to be Eva::ServoConfiguration::EncodersEnabled
    expect(enums[4]).to be Eva::ServoConfiguration::InvertAngles
    expect(enums[5]).to be Eva::Global::PowerControl
    expect(enums[6]).to be Eva::Errors::ErrorState
    expect(enums[7]).to be Eva::Dashboard::RobotState
    opt_enums = described_class.class_variable_get :@@optional_enums
    expect(opt_enums.length).to be 7
    expect(opt_enums[0]).to be Eva::ServoConfiguration::ServoMode
    expect(opt_enums[1]).to be Eva::ServoConfiguration::CommutationMode
    expect(opt_enums[2]).to be Eva::ServoConfiguration::EncodersEnabled
    expect(opt_enums[3]).to be Eva::ServoConfiguration::InvertAngles
    expect(opt_enums[4]).to be Eva::Global::PowerControl
    expect(opt_enums[5]).to be Eva::Errors::ErrorState
    expect(opt_enums[6]).to be Eva::Dashboard::RobotState
  end

  describe '.perform' do
    it 'deserializes and merges messages' do
      message = {a: 1}
      deserialized = {a: 432}
      result = {a: 'b'}
      expect(subject).to receive(:deserialize_message).once.with(message).and_return(deserialized)
      expect(subject).to receive(:merge_message!).once.with({}, deserialized) do | acc, _ |
        acc.merge!(result)
      end
      expect(RobotChannel).to receive(:broadcast_message).once.with(result)
      expect(CacheJob).to receive(:perform_later).once.with(result)

      messages = [message]
      subject.perform(messages)
    end
  end

  describe '.deserialize_message' do
    it 'deserializes any message' do
      raw = '123 - 321'

      data_source = {type: 123, 'testsuite' => 42}
      data_wrapper = double('wrapper', to_h: data_source)
      expect(Eva::Message).to receive(:decode).once.with(raw).and_return(data_wrapper)

      data = {'testsuite' => 42}
      message = {'message' => 'secret'}
      expect(subject).to receive(:deserialize_elements).once.with(data).and_return(message)

      result = subject.deserialize_message(raw)
      expect(result).to be(message)
    end

    it 'deserializes servo data' do
      src = {'type' => 5, 'servo_data' => {'servo_id' => 3, 'telemetry' => {'current' => 43}, 'errors' => {'error_state' => 2}}, 'action' => 'bullshit'}
      expected = {servo_data: {servo_id: 3, telemetry: {current: 43}, errors: {error_state: 2}}}
      serialized = Eva::Message.encode(RobotChannel.serialize_message(src))
      result = subject.deserialize_message(serialized)
      expect(result).to eq(expected)
    end

    it 'deserializes an enum with value 0' do
      src = {'type' => 3, 'sdo' => {'rw' => 0}}
      expected = {sdo: {rw: 0, index: 0, sub_index: 0, length: 0, data: 0, servo: 0}}
      serialized = Eva::Message.encode(RobotChannel.serialize_message(src))
      result = subject.deserialize_message(serialized)
      expect(result).to eq(expected)
    end

    it 'ignores an enum with value 0' do
      src = {'type' => 1, 'dashboard' => {'robotState' => 0}}
      expected = {dashboard: {}}
      serialized = Eva::Message.encode(RobotChannel.serialize_message(src))
      result = subject.deserialize_message(serialized)
      expect(result).to eq(expected)
    end
  end

  describe '.check_for_error' do
    it 'has no servo' do
      expect(subject).not_to receive(:send_slack_notification)
      subject.check_for_error({})
    end

    it 'has a servo but no error' do
      expect(subject).not_to receive(:send_slack_notification)
      subject.check_for_error({servo_data: {}})
    end

    it 'has errors but none set' do
      expect(subject).not_to receive(:send_slack_notification)
      subject.check_for_error({servo_data: {errors: {can_bus: true, error_state: Eva::Errors::ErrorState::ERROR_NONE}}})
    end

    it 'has a soft error' do
      expect(subject).to receive(:send_slack_notification).once.with('Robot Error', 'Soft Error from Servo 1: can bus', '#dd9900')
      subject.check_for_error({servo_data: {servo_id: 0, errors: {can_bus: true, error_state: Eva::Errors::ErrorState::ERROR_SOFT}}})
    end

    it 'has a hard error' do
      expect(subject).to receive(:send_slack_notification).once.with('Robot Error', 'Hard Error from Servo 2: output encoder', '#ff0000')
      subject.check_for_error({servo_data: {servo_id: 1, errors: {output_encoder: true, error_state: Eva::Errors::ErrorState::ERROR_HARD}}})
    end

    it 'has multiple errors' do
      expect(subject).to receive(:send_slack_notification).once.with('Robot Error', 'Hard Error from Servo 3: can bus, output encoder', '#ff0000')
      subject.check_for_error({servo_data: {servo_id: 2, errors: {can_bus: true, output_encoder: true, error_state: Eva::Errors::ErrorState::ERROR_HARD}}})
    end

    it 'has a unknown error (outdated error list)' do
      expect(subject).to receive(:send_slack_notification).once.with('Robot Error', 'Hard Error from Servo 4: Unknown error', '#ff0000')
      subject.check_for_error({servo_data: {servo_id: 3, errors: {LOL: true, error_state: Eva::Errors::ErrorState::ERROR_HARD}}})
    end
  end

  describe '.send_slack_notification' do
    it 'sens a POST to a slack hook' do
      payload = %q(payload={"channel":"#trial","fallback":"[TEST] THIS IS A TEST","color":"#233445","fields":[{"title":"TEST","value":"THIS IS A TEST"}]})
      http = double('http')
      allow(http).to receive(:request).once do |post|
        expect(post).to be_a(Net::HTTP::Post)
        expect(post.body).to eq(payload)
      end
      expect(Net::HTTP).to receive(:start).once.with('hooks.slack.com', 443, use_ssl: true).and_yield(http)
      expect(Net::HTTP::Post).to receive(:new).once.with('/services/T0M5VQTPY/B144Y3MV0/Uxj5OixMOt25NCmiRYjIa257').and_call_original

      subject.send_slack_notification('TEST', 'THIS IS A TEST', '#233445')
    end
  end
end

class DeserializeJob < MergeJob
  queue_as :deserialize
  require 'protocol/eva_pb'

  @@optional_enums = [
    Eva::ServoConfiguration::ServoMode,
    Eva::ServoConfiguration::CommutationMode,
    Eva::ServoConfiguration::EncodersEnabled,
    Eva::ServoConfiguration::InvertAngles,
    Eva::Global::PowerControl,
    Eva::Errors::ErrorState,
    Eva::Dashboard::RobotState,
  ].freeze

  @@enums = ([
    Eva::SDO::ReadWrite,
  ] + @@optional_enums).freeze

  @@potiential_errors = [
    :hardware_startup, :can_bus, :motor_encoder, :output_encoder, :drv8305, :board_temperature,
    :motor_temperature, :soft_current_limit, :hard_current_limit, :hall_effect_sensor,
    :pid_angle, :encoder_mismatch, :torque_sensor, :angle_range, :setpoints_mismatch, :setpoints_missing
  ].freeze
  @@token_slack = 'T0M5VQTPY/B144Y3MV0/Uxj5OixMOt25NCmiRYjIa257'.freeze

  def perform(messages)
    message = {}
    messages.each do | raw, _ |
      data = deserialize_message(raw)
      check_for_error(data) if Rails.env.production?
      merge_message!(message, self.class.adapt_servos(data))
    end
    RobotChannel.broadcast_message(message)
    CacheJob.perform_later(message)
  end

  private

  def check_for_error(data)
    servo = data[:servo_data]
    if (not servo.nil?) && (not servo[:errors].nil?)
      servo_id = servo[:servo_id]
      errors = servo[:errors]
      state = errors[:error_state]

      if state == Eva::Errors::ErrorState::ERROR_SOFT or state == Eva::Errors::ErrorState::ERROR_HARD
        error_list = []
        @@potiential_errors.map do | e |
          if errors.key?(e) and errors[e]
            error_list << e
          end
        end

        if error_list.length > 0
          error_string = error_list.map do | e |
            e.to_s.gsub!('_', ' ')
          end.join(', ')
        else
          error_string = 'Unknown error'
        end

        color = state == 2 ? '#dd9900' : '#ff0000'
        text = "#{state == 2 ? 'Soft Error' : 'Hard Error'} from Servo #{servo_id + 1}: #{error_string}"
        send_slack_notification('Robot Error', text, color)
      end

    end
  end

  def send_slack_notification(title, text, color)
    uri = URI('https://hooks.slack.com/')
    ssl = uri.scheme == 'https'

    payload = {
      channel: '#trial',
      fallback: "[#{title}] #{text}",
      color: color,
      fields: [
        {
          title: title,
          value: text
        }
      ]
    }

    Net::HTTP.start(uri.host, uri.port, :use_ssl => ssl) do |http|
        request = Net::HTTP::Post.new("/services/#{@@token_slack}")
        request.body = "payload=#{payload.to_json}"
        http.request request
    end
  end

  def deserialize_message(raw)
    data = Eva::Message.decode(raw).to_h
    data.reject! { | k, _ | k == :type }
    deserialize_elements(data)
  end

  def deserialize_elements(elements)
    elements.reject! { | _, v | v.nil? }
    elements.each do | k, v |
      if v.is_a?(Google::Protobuf::MessageExts)
        elements[k] =
          if v.class.parent == Google::Protobuf
            v.value
          else
            deserialize_elements(v.to_h)
          end
      elsif v.is_a?(Symbol)
        elements[k] = nil
        @@enums.each do | enum |
          if enum.const_defined?(v)
            constValue = enum.const_get(v)
            if !@@optional_enums.include?(enum) || constValue != 0
              elements[k] = constValue
            end
            break
          end
        end
        elements.delete(k) if elements[k] == nil
      end
    end
  end
end

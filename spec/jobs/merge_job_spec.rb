describe MergeJob, type: :job do
  make_private_public(described_class)

  subject { described_class.new }

  describe 'self.adapt_servos' do
    it 'extends servo_data' do
      data = {servo_data: {servo_id: 3, truc: 'abc'}, abc: 123}
      result = subject.class.adapt_servos(data)
      expect(result).to eq({'servo_data' => [{}, {}, {}, {'servo_id' => 3, 'truc' => 'abc'}, {}, {}, {}], 'abc' => 123})
    end

    it 'does nothing' do
      data = {servo_data2: {id: 123, truc: 'abc'}}
      result = subject.class.adapt_servos(data)
      expect(result).to eq({'servo_data2' => {'id' => 123, 'truc' => 'abc'}})
    end
  end

  describe 'merge_message!' do
    it 'calls recursive_merge!' do
      dest = {a: 1}
      source = {b: 3}
      expect(subject).to receive(:recursive_merge!).once.with(dest, source).and_return(true)
      result = subject.merge_message!(dest, source)
      expect(result).to be true
    end
  end

  let (:cinput1) { {:testsuite=>{:heartbeat_control=>{:timeout=>2345676511, :interval=>543, :enabled=>true}, :servo_data =>[{:servo_id=>0,:telemetry=>{:drive_temp=>2, :motor_temp=>3, :current=>4, :position=>5}, :pid_settings=>{:position=>{:p=>1.0, :i=>2.0, :d=>3.0}, :velocity=>{:p=>2.0, :i=>3.0, :d=>1.0}, :torque=>{:p=>3.0, :i=>1.0, :d=>2.0}}, :heartbeat=>{:code=>1, :timestamp=>1, :valid=>true}, :servo_configuration=>{:servo_mode=>2, :commutation_mode=>0}}], :message=>"coucou"}} }
  let (:coutput1) { {"testsuite"=>{"heartbeat_control"=>{"timeout"=>2345676511, "interval"=>543, "enabled"=>true}, "servo_data"=>[{"servo_id"=>0,"telemetry"=>{"drive_temp"=>2, "motor_temp"=>3, "current"=>4, "position"=>5}, "pid_settings"=>{"position"=>{"p"=>1.0, "i"=>2.0, "d"=>3.0}, "velocity"=>{"p"=>2.0, "i"=>3.0, "d"=>1.0}, "torque"=>{"p"=>3.0, "i"=>1.0, "d"=>2.0}}, "heartbeat"=>{"code"=>1, "timestamp"=>1, "valid"=>true}, "servo_configuration"=>{"servo_mode"=>2, "commutation_mode"=>0}}, {}, {}, {}, {}, {}, {}], "message"=>["coucou"]}} }

  let (:cinput2) { {:testsuite=>{:heartbeat_control=>{:timeout=>32}}} }
  let (:coutput2) { {"testsuite"=>{"heartbeat_control"=>{"timeout"=>32, "interval"=>543, "enabled"=>true}, "servo_data"=>[{"servo_id"=>0,"telemetry"=>{"drive_temp"=>2, "motor_temp"=>3, "current"=>4, "position"=>5}, "pid_settings"=>{"position"=>{"p"=>1.0, "i"=>2.0, "d"=>3.0}, "velocity"=>{"p"=>2.0, "i"=>3.0, "d"=>1.0}, "torque"=>{"p"=>3.0, "i"=>1.0, "d"=>2.0}}, "heartbeat"=>{"code"=>1, "timestamp"=>1, "valid"=>true}, "servo_configuration"=>{"servo_mode"=>2, "commutation_mode"=>0}}, {}, {}, {}, {}, {}, {}], "message"=>["coucou"]}} }

  let (:cinput3) { {:testsuite=>{:servo_data=>[{:servo_id=>0,:telemetry=>{:drive_temp=>3}}]}} }
  let (:coutput3) { {"testsuite"=>{"heartbeat_control"=>{"timeout"=>2345676511, "interval"=>543, "enabled"=>true}, "servo_data"=>[{"servo_id"=>0,"telemetry"=>{"drive_temp"=>3, "motor_temp"=>3, "current"=>4, "position"=>5}, "pid_settings"=>{"position"=>{"p"=>1.0, "i"=>2.0, "d"=>3.0}, "velocity"=>{"p"=>2.0, "i"=>3.0, "d"=>1.0}, "torque"=>{"p"=>3.0, "i"=>1.0, "d"=>2.0}}, "heartbeat"=>{"code"=>1, "timestamp"=>1, "valid"=>true}, "servo_configuration"=>{"servo_mode"=>2, "commutation_mode"=>0}}, {}, {}, {}, {}, {}, {}], "message"=>["coucou"]}} }

  let (:cinput4) { {:testsuite=>{:servo_data=>[nil, {:servo_id=>1,:telemetry=>{:drive_temp=>3}}]}} }
  let (:coutput4) { {"testsuite"=>{"heartbeat_control"=>{"timeout"=>2345676511, "interval"=>543, "enabled"=>true}, "servo_data"=>[{"servo_id"=>0,"telemetry"=>{"drive_temp"=>2, "motor_temp"=>3, "current"=>4, "position"=>5}, "pid_settings"=>{"position"=>{"p"=>1.0, "i"=>2.0, "d"=>3.0}, "velocity"=>{"p"=>2.0, "i"=>3.0, "d"=>1.0}, "torque"=>{"p"=>3.0, "i"=>1.0, "d"=>2.0}}, "heartbeat"=>{"code"=>1, "timestamp"=>1, "valid"=>true}, "servo_configuration"=>{"servo_mode"=>2, "commutation_mode"=>0}}, {"servo_id"=>1,"telemetry"=>{"drive_temp"=>3}}, {}, {}, {}, {}, {}], "message"=>["coucou"]}} }

  let (:cinput5) { {:testsuite=>{:sdo=>[1, 2, 3]}, :bd_waypoint=>1, :a=>{:b=>2, :action=>3, :jog=>21, :timeline=>'abc'}} }
  let (:coutput5) { {"testsuite"=>{}, "a"=>{"b"=>2}} }

  describe 'merge_cache!' do
    it 'calls recursive_merge!' do
      dest = {a: 1}
      source = {b: 3}
      options = {messages: 1000, strip_cache: true, string_key: true}
      expect(subject).to receive(:recursive_merge!).once.with(dest, source, **options).and_return(false)
      result = subject.merge_cache!(dest, source)
      expect(result).to be false
    end

    it 'merges empty hash correctly' do
      result = {}
      changed = subject.merge_cache!(result, cinput1)
      expect(changed).to be true
      expect(result).to eq(coutput1)
    end

    it 'merges successive data correctly' do
      result = {}
      changed = subject.merge_cache!(result, cinput1)
      expect(changed).to be true
      changed = subject.merge_cache!(result, cinput2)
      expect(changed).to be true
      expect(result).to eq(coutput2)
    end

    it 'merges servos correctly' do
      result = {}
      changed = subject.merge_cache!(result, cinput1)
      expect(changed).to be true
      changed = subject.merge_cache!(result, cinput3)
      expect(changed).to be true
      expect(result).to eq(coutput3)
    end

    it 'merges servos correctly (different indexes)' do
      result = {}
      changed = subject.merge_cache!(result, cinput1)
      expect(changed).to be true
      changed = subject.merge_cache!(result, cinput4)
      expect(changed).to be true
      expect(result).to eq(coutput4)
    end

    it 'strips some info' do
      result = {}
      changed = subject.merge_cache!(result, cinput5)
      expect(changed).to be true
      expect(result).to eq(coutput5)
    end
  end

  describe 'recursive_merge!' do
    # TODO: Transfer merge_cache! tests here

    context 'when using key strings' do
      let (:input_replace_1) { {testsuite: {message: '123'}} }
      let (:input_replace_2) { {testsuite: {message: ['456']}} }
      let (:output_replace)  { {'testsuite' => {'message' => ['123', '456']}} }

      it 'replaces values correctly' do
        options = {string_key: true}
        input = {}
        changed = subject.recursive_merge!(input, input_replace_1, **options)
        expect(changed).to be true
        changed = subject.recursive_merge!(input, input_replace_2, **options)
        expect(changed).to be true
        expect(input).to eq(output_replace)
      end
    end

    context 'when dropping messages' do
      let (:cache_messages_too_long)  { {:testsuite=>{:message=>["coucou0", "coucou1", "coucou2", "coucou3", "coucou4"]}} }
      let (:input_messages_too_long)  { {:testsuite=>{:message=>"coucou5"}} }
      let (:output_messages_too_long) { {:testsuite=>{:message=>["coucou1", "coucou2", "coucou3", "coucou4", "coucou5"]}} }

      it 'drops messages they go over the threshold' do
        result = cache_messages_too_long
        changed = subject.recursive_merge!(result, input_messages_too_long, messages: 5)
        expect(changed).to be true
        expect(result).to eq(output_messages_too_long)
      end
    end

    context 'when using backdriving waypoints' do
      let (:cache_bd_waypoints)  { {} }
      let (:input_bd_waypoints)  { {:bd_waypoint=>{:a1=>1,:a5=>2}} }
      let (:output_bd_waypoints) { {:bd_waypoint=>[{:a1=>1,:a5=>2}]} }
      let (:input_bd_waypoints2)  { {:bd_waypoint=>{:a2=>42,:a3=>21}} }
      let (:output_bd_waypoints2) { {:bd_waypoint=>[{:a1=>1,:a5=>2}, {:a2=>42,:a3=>21}]} }

      it 'creates an array of backdriving waypoints' do
        result = cache_bd_waypoints
        changed = subject.recursive_merge!(result, input_bd_waypoints, messages: 0)
        expect(changed).to be true
        expect(result).to eq(output_bd_waypoints)
      end

      it 'appends to the array' do
        result = output_bd_waypoints
        changed = subject.recursive_merge!(result, input_bd_waypoints2, messages: 0)
        expect(changed).to be true
        expect(result).to eq(output_bd_waypoints2)
      end
    end
  end

end

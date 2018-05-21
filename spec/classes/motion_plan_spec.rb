describe MotionPlan do
  describe 'self.trajectory_array' do
    let (:mp_input) {
      dbl = double('p')
      allow(dbl).to receive(:get_array_of_float).with(0, 11).and_return([0.1, 0.2, 0.3, 1, 2, 3, 4, 5, 6, 1.0])
      dbl2 = double('p')
      allow(dbl2).to receive(:get_array_of_float).with(0, 11).and_return([0.3, 0.2, 0.1, 7, 6, 5, 4, 3, 2, 0.0])
      [dbl, dbl2]
    }

    it 'extracts the motion planning info' do
      ptr = double('pointer')
      allow(ptr).to receive(:get_pointer).twice.and_return(0, 2)
      allow(ptr).to receive(:get_array_of_pointer).with(16, 2).and_return(mp_input)

      result = described_class.trajectory_array(ptr)
      expect(result.length).to be(2)
      expect(result[0]).to eq({x: 0.1, y: 0.2, z: 0.3, a0: 1, a1: 2, a2: 3, a3: 4, a4: 5, a5: 6, success: true})
      expect(result[1]).to eq({x: 0.3, y: 0.2, z: 0.1, a0: 7, a1: 6, a2: 5, a3: 4, a4: 3, a5: 2, success: false})
    end

    it 'adapts to the pointer size' do
      stub_const("FFI::Pointer::SIZE", 4)

      ptr = spy('pointer')
      described_class.trajectory_array(ptr)

      expect(ptr).to have_received(:get_pointer).with(0).ordered
      expect(ptr).to have_received(:get_pointer).with(4).ordered
    end
  end
end

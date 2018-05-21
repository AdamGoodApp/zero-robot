describe Scene do

  let(:toolpath) { FactoryGirl.create :toolpath }
  let(:scene) { Scene.new(toolpath) }

  context 'on creation' do
    it 'initializes with metadata' do
      expect(scene.metadata).not_to be_nil
    end

    it 'initializes with waypoints' do
      expect(scene.waypoints).not_to be_nil
    end

    it 'initializes with timeline' do
      expect(scene.timeline).not_to be_nil
    end
  end

  context '.build toolpath' do
    it 'returns a trajectory' do
      expect(scene.build_toolpath).not_to be_empty
    end
  end


end
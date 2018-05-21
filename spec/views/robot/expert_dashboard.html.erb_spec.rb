describe 'robot/expert_dashboard.html.erb', ssr: true do
  login_user
  fetch_robot
  before(:each) do
    @view_config = {
      joint_number: 12
    }
    @should_prerender = true
  end

  shared_context 'a robot dashboard view' do
    it "renders the robot" do
      render
      expect(rendered).to match("Servo 12")
    end
  end

  context 'when first servo timeout' do
    before(:each) do
      @cache = {"servo_data"=>[{"heartbeat"=>{"valid"=>"false"}}]}
    end

    it_behaves_like 'a robot dashboard view'
    it 'renders the value correctly' do
      render
      expect(rendered).to match("<div class=\"property-value font-weight-bold\"[^>]*><!--[^>]*-->Timeout<!--[^>]*--></div>")
    end
  end
end

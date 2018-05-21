describe 'robot/viewer.html.erb', ssr: true do
  login_user

  before (:each) do
    @view_config = {
    }
    @should_prerender = true
  end

  context 'when accessed' do
    it 'renders the canvas' do
      render
      expect(rendered).to match('div class="viewer-3d')
    end
  end
end

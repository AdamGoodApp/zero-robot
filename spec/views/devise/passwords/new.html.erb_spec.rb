describe 'devise/passwords/new.html.erb', ssr: true do
  login_user
  config_view [
                [:resource, FakeUser.new('a')],
                [:resource_name, :user],
                [:controller_name, :passwords],
                [:devise_mapping, FakeMapping.new(:recoverable, :rememberable)]
              ]

  before (:each) do
    @should_prerender = true
  end

  context 'when rendered' do
    it 'renders the form (email) correctly' do
      render
      expect(rendered).to match(url_for(controller: 'devise/passwords', action: 'create'))
      expect(rendered).to match('input[^>]*id="user_email"')
      expect(rendered).to match('button[^>]*type="submit"')
    end

    it_behaves_like 'a view that renders errors', {email: ['Invalid 123']}
    it_behaves_like 'a view that renders errors', {email: ['Invalid 123', 'Koukou']}
  end
end

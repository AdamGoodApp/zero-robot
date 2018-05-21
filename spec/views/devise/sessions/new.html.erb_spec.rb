describe 'devise/sessions/new.html.erb', ssr: true do
  login_user
  config_view [
                [:resource, FakeUser.new('a')],
                [:resource_name, :user],
                [:controller_name, :sessions],
                [:devise_mapping, FakeMapping.new(:recoverable, :rememberable)]
              ]

  before (:each) do
    @should_prerender = true
  end

  context 'when rendered' do
    it 'renders the form (email, password, remember me) correctly' do
      render
      expect(rendered).to match(url_for(controller: 'devise/sessions', action: 'create'))
      expect(rendered).to match('input[^>]*id="user_email"')
      expect(rendered).to match('input[^>]*id="user_password"')
      expect(rendered).to match('input[^>]*id="user_remember_me"')
      expect(rendered).to match('button[^>]*type="submit"')
    end
  end

  context 'when resource is recoverable' do
    it 'renders the password recovery link' do
      render
      expect(rendered).to match('Forgot your password')
      expect(rendered).to match(url_for(controller: 'devise/passwords', action: 'new'))
    end
  end
end

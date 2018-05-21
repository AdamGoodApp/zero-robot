describe 'devise/passwords/edit.html.erb', ssr: true do
  login_user
  config_view [
                [:resource, FakeUser.new('a')],
                [:resource_name, :user],
                [:controller_name, :passwords],
                [:devise_mapping, FakeMapping.new(:recoverable, :rememberable)]
              ]

  before (:each) do
    @should_prerender = true
    @minimum_password_length = 7
  end

  context 'when rendered' do
    it 'renders the form (token, passwords) correctly' do
      render
      expect(rendered).to match(url_for(controller: 'devise/passwords', action: 'update'))
      expect(rendered).to match('input[^>]*id="user_reset_password_token"')
      expect(rendered).to match('input[^>]*id="user_password"')
      expect(rendered).to match('input[^>]*id="user_password_confirmation"')
      expect(rendered).to match('button[^>]*type="submit"')

      expect(rendered).to match('7.* characters minimum')
    end

    it_behaves_like 'a view that renders errors', {reset_password_token: ['Invalid 000'], password: ['Invalid 123'], password_confirmation: ['Invalid 456']}
    it_behaves_like 'a view that renders errors', {reset_password_token: ['Invalid 000', '_dfg_'], password: ['Invalid 123', '_sdd_'], password_confirmation: ['Invalid 456', '_sdw_']}
  end
end

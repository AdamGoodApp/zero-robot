def check_menu(admin = true)
  expect(rendered).to match('Dashboard')
  expect(rendered).to match(url_for(controller: 'robot', action: 'dashboard'))
  expect(rendered).to match('Viewer')
  expect(rendered).to match(url_for(controller: 'robot', action: 'viewer'))
  if admin
    expect(rendered).to match('Expert Dashboard')
    expect(rendered).to match(url_for(controller: 'robot', action: 'expert_dashboard'))
  else
    expect(rendered).not_to match('Expert Dashboard')
    expect(rendered).not_to match('"' + url_for(controller: 'robot', action: 'expert_dashboard'))
  end
  expect(rendered).to match(user.email)
  expect(rendered).to match('Profile')
  expect(rendered).to match(url_for(controller: 'users/registrations', action: 'edit'))
  expect(rendered).to match('Logout')
  expect(rendered).to match(url_for(controller: 'users/sessions', action: 'destroy'))
end

describe 'shared/_header.html.erb', ssr: true do
  before (:each) do
    @should_prerender = true
  end

  context 'when not setup' do
    it 'renders an empty navbar' do
      make_pending('TODO')
    end
  end

  context 'when not signed in' do
    it 'renders the sign in and sign up buttons' do
      render
      expect(rendered).to match('Login')
      expect(rendered).to match(url_for(controller: 'users/sessions', action: 'new'))
      expect(rendered).to match('Sign up')
      expect(rendered).to match(url_for(controller: 'users/registrations', action: 'new'))
    end
  end

  context 'when signed in' do
    login_user
    before (:each) do
      @user = user
    end

    it 'renders the menu correctly' do
      render
      check_menu
    end

    it 'renders the menu correctly (not admin)' do
      @ability = Object.new.extend(CanCan::Ability)
      @ability.cannot :read_expert_dashboard, user
      allow(controller).to receive(:current_ability).and_return(@ability)
      render
      check_menu(false)
    end

    shared_context 'a menu with the correct active page' do | url, link |
      context "when visiting #{url}" do
        before (:each) do
          allow(view).to receive(:current_page?) do | options |
            url == url_for(options)
          end
        end

        it 'renders the active class correctly' do
          render
          if link.nil?
            expect(rendered).to_not match("active[^\"]*\">[^<]*<a href=\"/\"")
            expect(rendered).to_not match("active[^\"]*\">[^<]*<a href=\"/dashboard\"")
          else
            expect(rendered).to match("active[^\"]*\"[^>]*>[^<]*<a[^>]* href=\"#{link}\"")
          end
        end
      end
    end

    it_behaves_like 'a menu with the correct active page', '/', '/dashboard'
    it_behaves_like 'a menu with the correct active page', '/dashboard', '/dashboard'
    it_behaves_like 'a menu with the correct active page', '/viewer', '/viewer'
    it_behaves_like 'a menu with the correct active page', '/expert_dashboard', '/expert_dashboard'
    it_behaves_like 'a menu with the correct active page', '/users/edit', nil
  end
end

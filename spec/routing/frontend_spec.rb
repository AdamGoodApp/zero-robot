describe 'FrontEndRoutes' do

  shared_context 'a front-end route' do | route, controller, action, method = :get |
    it 'routes correctly' do
      expect(method => route).to route_to(
                                   :controller => controller,
                                   :action => action
                                 )
    end
  end

  shared_context 'a front-end route with an argument' do | route, controller, action, arg, value, method = :get |
    it 'routes correctly' do
      expect(method => route).to route_to(
                                   :controller => controller,
                                   :action => action,
                                   arg => value
                                 )
    end
  end

  shared_context 'a non-routable address' do | route, method = :get |
    it 'can\'t be routed correctly' do
      expect(method => route).to_not be_routable
    end
  end

  describe '/setup' do
    it_behaves_like 'a front-end route', '/setup', 'application', 'setup'
  end

  describe '/' do
    it_behaves_like 'a front-end route', '/', 'robot', 'dashboard'
  end

  describe '/dashboard' do
    it_behaves_like 'a front-end route', '/dashboard', 'robot', 'dashboard'
  end

  describe '/viewer' do
    it_behaves_like 'a front-end route', '/viewer', 'robot', 'viewer'
  end

  describe '/expert_dashboard' do
    it_behaves_like 'a front-end route', '/expert_dashboard', 'robot', 'expert_dashboard'
  end

  describe '/token' do
    describe '/add' do
      it_behaves_like 'a front-end route', '/token/add', 'users/registrations', 'add_token', :put
    end

    describe '/remove' do
      it_behaves_like 'a non-routable address', '/token/remove', :delete
      it_behaves_like 'a front-end route with an argument', '/token/remove/1', 'users/registrations', 'remove_token', :id, '1', :delete
    end
  end

  describe '/users' do
    it_behaves_like 'a front-end route', '/users/sign_in', 'users/sessions', 'new', :get
    it_behaves_like 'a front-end route', '/users/sign_in', 'users/sessions', 'create', :post
    it_behaves_like 'a front-end route', '/users/sign_out', 'users/sessions', 'destroy', :get

    it_behaves_like 'a front-end route', '/users/password/new', 'devise/passwords', 'new', :get
    it_behaves_like 'a front-end route', '/users/password', 'devise/passwords', 'create', :post

    it_behaves_like 'a front-end route', '/users/sign_up', 'users/registrations', 'new', :get
    it_behaves_like 'a front-end route', '/users', 'users/registrations', 'create', :post
    it_behaves_like 'a front-end route', '/users/edit', 'users/registrations', 'edit', :get
    it_behaves_like 'a front-end route', '/users', 'users/registrations', 'update', :put
    it_behaves_like 'a front-end route', '/users', 'users/registrations', 'destroy', :delete
  end
end

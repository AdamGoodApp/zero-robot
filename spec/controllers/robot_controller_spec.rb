
def good_request(page)
  before(:each) do
    get page
  end
end

describe RobotController do
  fetch_robot

  describe '#dashboard' do

    context 'when not signed in' do
      good_request :dashboard

      it_behaves_like 'a need to sign in request'
    end

    context 'when signed in' do
      login_user

      before(:each) do
        expect(CacheJob).to receive(:read_cache!).and_return(42)
      end

      good_request :dashboard

      it_behaves_like 'a successful rendering', 'dashboard'

      it 'sets all the values for React' do
        config = assigns(:view_config)

        expect(config).to be_a(Hash)
        expect(config[:cache]).to be(42)
        expect(config[:toolpaths]).to be_a(Array)
        expect(config[:toolpaths].length).to be 1
      end
    end
  end


  describe '#expert_dashboard' do

    context 'when not signed in' do
      good_request :expert_dashboard

      it_behaves_like 'a need to sign in request'
    end

    context 'when signed in' do
      login_user

      context 'when has access' do
        before(:each) do
          expect(CacheJob).to receive(:read_cache!).and_return(42)
        end

        good_request :expert_dashboard

        it_behaves_like 'a successful rendering', 'expert_dashboard'

        it 'sets all the values for React' do
          config = assigns(:view_config)

          expect(config).to be_a(Hash)
          expect(config[:joint_number]).to be 6
          expect(config[:cache]).to be 42
        end
      end

      context 'when does not have access' do
        before (:each) do
          allow(controller).to receive(:authorize!) do raise CanCan::AccessDenied.new('Hello') end
        end

        good_request :expert_dashboard

        it_behaves_like 'a access denied request', 'Hello'
      end
    end
  end

  describe '#viewer' do

    context 'when not signed in' do
      good_request :viewer

      it_behaves_like 'a need to sign in request'
    end

    context 'when signed in' do
      login_user
      create_user2(true)

      before(:each) do
        expect(CacheJob).to receive(:read_cache!).and_return({a: 123})
      end

      good_request :viewer

      it_behaves_like 'a successful rendering', 'viewer'

      it 'sets all the values for React' do
        config = assigns(:view_config)

        expect(config).to be_a(Hash)
        expect(config[:joint_number]).to be 6
        expect(config[:online_enabled]).to be true
        expect(config[:cache]).to be_a Hash
        expect(config[:cache]).to eq({a: 123})
        expect(config[:toolpaths]).to be_a Array
        expect(config[:toolpaths].length).to be 1
        expect(config[:users]).to be_a Array
        expect(config[:users].length).to be 1
      end
    end

    context 'when signed in (non-admin)' do
      create_user2(true)
      login_user

      before(:each) do
        expect(CacheJob).to receive(:read_cache!).and_return({a: 123})
      end

      good_request :viewer

      it_behaves_like 'a successful rendering', 'viewer'

      it 'sets all the values for React' do
        config = assigns(:view_config)

        expect(config).to be_a(Hash)
        expect(config[:joint_number]).to be 6
        expect(config[:online_enabled]).to be false
        expect(config[:cache]).to be_a Hash
        expect(config[:cache]).to eq({a: 123})
        expect(config[:toolpaths]).to be_a Array
        expect(config[:toolpaths].length).to be 1
        expect(config[:users]).to be_a Array
        expect(config[:users].length).to be 1
      end
    end
  end

  describe '#get_toolpaths' do
    make_pending('TODO')
  end

  describe '#get_users' do
    make_pending('TODO')
  end

  describe '#get_joint_number' do
      make_pending('TODO')
  end
end

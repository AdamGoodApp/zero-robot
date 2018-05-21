def login(email, password)
  before (:each) do
    args = {user: {}}

    if email != ''
      args[:user][:email] = email
    end
    if password != ''
      args[:user][:password] = password
    end

    post :create, params: args
  end
end

def logout(works:)
  setup_devise

  before (:each) do
    if works
      expect(ActionCable.server).to receive(:disconnect).once.with(current_user: user)
    else
      expect(ActionCable.server).not_to receive(:disconnect)
    end
    delete :destroy
  end
end

describe Users::SessionsController do

  describe '#create' do

    context 'when not signed in' do
      create_user(true)
      create_user2(true)

      # Nothing
      context 'when using no email and no password' do
        login '', ''

        it_behaves_like 'a failed sign in request'
      end

      # Wrong
      context 'when using a wrong email and no password' do
        login 'a@a.a', ''

        it_behaves_like 'a failed sign in request'
      end

      context 'when using no email and a wrong password' do
        login '', 'coucou'

        it_behaves_like 'a failed sign in request'
      end

      context 'when using a wrong email and a wrong password' do
        login 'a@a.a', 'coucou'

        it_behaves_like 'a failed sign in request'
      end

      # Existing Email
      context 'when using an existing email and no password' do
        login 'ar@getautomata.com', ''

        it_behaves_like 'a failed sign in request'
      end

      context 'when using an existing email and a wrong password' do
        login 'ar@getautomata.com', 'coucou'

        it_behaves_like 'a failed sign in request'
      end

      # Existing Password
      context 'when using no email and an existing password' do
        login '', 'helloworld182'

        it_behaves_like 'a failed sign in request'
      end

      context 'when using a wrong email and an existing password' do
        login 'a@a.a', 'helloworld182'

        it_behaves_like 'a failed sign in request'
      end

      # Existing Both
      context 'when using an existing email and an existing password' do
        login 'ar@getautomata.com', 'secretPASS'

        it_behaves_like 'a failed sign in request'
      end

      context 'when using the right email and the right password' do
        login 'ar@getautomata.com', 'helloworld182'

        it_behaves_like 'a successful sign in request' do
          let (:test_user) { @user }
        end
      end
    end


    context 'when signed in' do
      login_user
      create_user2(true)

      # Nothing
      context 'when using no email and no password' do
        login '', ''

        it_behaves_like 'a already signed in request'
      end

      # Wrong
      context 'when using a wrong email and no password' do
        login 'a@a.a', ''

        it_behaves_like 'a already signed in request'
      end

      context 'when using no email and a wrong password' do
        login '', 'coucou'

        it_behaves_like 'a already signed in request'
      end

      context 'when using a wrong email and a wrong password' do
        login 'a@a.a', 'coucou'

        it_behaves_like 'a already signed in request'
      end

      # Existing Email
      context 'when using an existing email and no password' do
        login 'ar@getautomata.com', ''

        it_behaves_like 'a already signed in request'
      end

      context 'when using an existing email and a wrong password' do
        login 'ar@getautomata.com', 'coucou'

        it_behaves_like 'a already signed in request'
      end

      # Existing Password
      context 'when using no email and an existing password' do
        login '', 'helloworld182'

        it_behaves_like 'a already signed in request'
      end

      context 'when using a wrong email and an existing password' do
        login 'a@a.a', 'helloworld182'

        it_behaves_like 'a already signed in request'
      end

      # Existing Both
      context 'when using an existing email and an existing password' do
        login 'ar@getautomata.com', 'secretPASS'

        it_behaves_like 'a already signed in request'
      end

      context 'when using the right email and the right password' do
        login 'ar@getautomata.com', 'helloworld182'

        it_behaves_like 'a already signed in request'
      end
    end

  end

  describe '#destroy' do

    context 'when not signed in' do
      logout(works: false)

      it_behaves_like 'a successful sign out request'
    end


    context 'when signed in' do
      login_user
      logout(works: true)

      it_behaves_like 'a successful sign out request'
    end

  end

end

def new_password(email)
  before(:each) do
    if email != ''
      post :create, params: { user: {email: email} }
    else
      post :create
    end
  end
end

def edit_password(request)
  before(:each) do
    actual_user = ((defined? user) != nil) ? user : @user
    if request
      token = actual_user.set_reset_password_token
      get :edit, params: { reset_password_token: token }
    else
      get :edit
    end
  end
end

def update_password(pass1, pass2, request_token=:inc)
  before(:each) do
    actual_user = ((defined? user) != nil) ? user : @user
    token = nil
    if request_token != :none
      token = actual_user.set_reset_password_token
      if request_token == :wrong
        token = 'dauphin'
      elsif request_token == :expired
        actual_user.reset_password_sent_at = Time.now.utc - (Devise.reset_password_within * 1.5)
        actual_user.save(validate: false)
      end
    end
    put :update, params: { user: {password: pass1, password_confirmation: pass2, reset_password_token: token} }
  end
end

# Redefine a function has public so we can get the result for testing purposes
module Devise::Models::Recoverable
  public :set_reset_password_token
end

describe Devise::PasswordsController do

  describe '#create' do

    context 'when not signed in' do
      create_user(true)

      context 'when using no email' do
        new_password ''

        it_behaves_like 'a successful rendering', 'devise/passwords/new'
      end

      context 'when using a wrong email' do
        new_password 'a@a.a'

        it_behaves_like 'a successful rendering', 'devise/passwords/new'
      end

      context 'when using an existing email' do
        new_password 'ar@getautomata.com'

        it_behaves_like 'a successful forgot password request'
      end
    end


    context 'when signed in' do
      login_user

      context 'when using no email' do
        new_password ''

        it_behaves_like 'a already signed in request'
      end

      context 'when using a wrong email' do
        new_password 'a@a.a'

        it_behaves_like 'a already signed in request'
      end

      context 'when using an existing email' do
        new_password 'ar@getautomata.com'

        it_behaves_like 'a already signed in request'
      end
    end

  end

  describe '#edit' do

    context 'when not signed in' do
      create_user(true)

      context 'when not using a token' do
        edit_password false

        it_behaves_like 'a logged out request'
        it_behaves_like 'a redirected request', :new_user_session_path
        it_behaves_like 'a request with a flash', :alert, 'You can\'t access this page without coming from a password reset email. If you do come from a password reset email, please make sure you used the full URL provided.'
      end

      context 'when using a token' do
        edit_password true

        it_behaves_like 'a logged out request'
        it_behaves_like 'a successful rendering', 'devise/passwords/edit'
      end

    end


    context 'when signed in' do
      login_user

      context 'when not using a token' do
        edit_password false

        it_behaves_like 'a already signed in request'
      end

      context 'when using a token' do
        edit_password true

        it_behaves_like 'a already signed in request'
      end
    end

  end

  describe '#update' do

    context 'when not signed in' do
      create_user(true)

      context 'with no passwords' do
        update_password '', ''

        it_behaves_like 'a failed reset password request'
      end

      context 'with one password' do
        update_password 'hellOworld', ''

        it_behaves_like 'a failed reset password request'
      end

      context 'with another password' do
        update_password '', 'hellOworld'

        it_behaves_like 'a failed reset password request'
      end

      context 'with different passwords' do
        update_password 'hellOworld', 'coucou42'

        it_behaves_like 'a failed reset password request'
      end

      context 'with same passwords (too short)' do
        update_password '123', '123'

        it_behaves_like 'a failed reset password request'
      end

      context 'with same passwords (no token)' do
        update_password 'hellOworld', 'hellOworld', :none

        it_behaves_like 'a failed reset password request'
      end

      context 'with same passwords (wrong token)' do
        update_password 'hellOworld', 'hellOworld', :wrong

        it_behaves_like 'a failed reset password request'
      end

      context 'with same passwords (expired token)' do
        update_password 'hellOworld', 'hellOworld', :expired

        it_behaves_like 'a failed reset password request'
      end

      context 'with same passwords (as before)' do
        update_password 'helloworld182', 'helloworld182'

        it_behaves_like 'a successful reset password request' do
          let (:test_user) { @user }
        end
      end

      context 'with same passwords' do
        update_password 'hellOworld', 'hellOworld'

        it_behaves_like 'a successful reset password request' do
          let (:test_user) { @user }
        end
      end

    end


    context 'when signed in' do
      login_user

      context 'with no passwords' do
        update_password '', ''

        it_behaves_like 'a already signed in request'
      end

      context 'with one password' do
        update_password 'hellOworld', ''

        it_behaves_like 'a already signed in request'
      end

      context 'with another password' do
        update_password '', 'hellOworld'

        it_behaves_like 'a already signed in request'
      end

      context 'with different passwords' do
        update_password 'hellOworld', 'coucou42'

        it_behaves_like 'a already signed in request'
      end

      context 'with same passwords (too short)' do
        update_password '123', '123'

        it_behaves_like 'a already signed in request'
      end

      context 'with same passwords (no token)' do
        update_password 'hellOworld', 'hellOworld', :none

        it_behaves_like 'a already signed in request'
      end

      context 'with same passwords (wrong token)' do
        update_password 'hellOworld', 'hellOworld', :wrong

        it_behaves_like 'a already signed in request'
      end

      context 'with same passwords (expired token)' do
        update_password 'hellOworld', 'hellOworld', :expired

        it_behaves_like 'a already signed in request'
      end

      context 'with same passwords (as before)' do
        update_password 'helloworld182', 'helloworld182'

        it_behaves_like 'a already signed in request'
      end

      context 'with same passwords' do
        update_password 'hellOworld', 'hellOworld'

        it_behaves_like 'a already signed in request'
      end
    end

  end

end
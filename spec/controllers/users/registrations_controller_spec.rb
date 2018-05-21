def create_token
  setup_devise
  before(:each) do
    put :add_token
  end
end

def delete_a_token
  setup_devise
  before(:each) do
    id = 1
    if defined? user
      if user.api_keys.first
        id = user.api_keys.first
      end
    end
    delete :remove_token, params: { id: id }
  end
end

def check_tokens_number(number)
  it "should have #{number} tokens" do
    expect(user.api_keys.count).to eq number
  end
end

def delete_user(works:)
  before (:each) do
    if works
      expect(RobotChannel).to receive(:deleted_user).once.with({id: user.id})
    else
      expect(RobotChannel).not_to receive(:deleted_user)
    end
    delete :destroy
  end
end

def sign_up_user(email, pass1, pass2, works:)
  before (:each) do
    if works
      expect(RobotChannel).to receive(:new_user).once.with({id: @user.id + 1, name: email})
    else
      expect(RobotChannel).not_to receive(:new_user)
    end
    post :create, params: { user: {email: email, password: pass1, password_confirmation: pass2} }
  end
end

def edit_user(email, curr_pass, pass1, pass2, works:)
  before (:each) do
    if works
      expect(RobotChannel).to receive(:updated_user).once.with({id: user.id, name: email})
    else
      expect(RobotChannel).not_to receive(:updated_user)
    end
    post :update, params: { user: {email: email, current_password: curr_pass, password: pass1, password_confirmation: pass2} }
  end
end

describe Users::RegistrationsController do

  describe '#create' do

    context 'when not signed in' do
      create_user(true)

      context 'with missing informations' do
        context 'with no information' do
          it_behaves_like 'a failed sign up request' do
            sign_up_user '', '', '', works: false
          end
        end

        context 'with an email and no passwords' do
          it_behaves_like 'a failed sign up request' do
            sign_up_user 'm@getautomata.com', '', '', works: false
          end
        end

        context 'with an email and one password' do
          it_behaves_like 'a failed sign up request' do
            sign_up_user 'm@getautomata.com', 'helloWORLD', '', works: false
          end
        end

        context 'with no email and two passwords' do
          it_behaves_like 'a failed sign up request' do
            sign_up_user '', 'helloWORLD', 'helloWORLD', works: false
          end
        end
      end

      context 'with wrong informations' do
        context 'with a wrong email and different passwords' do
          it_behaves_like 'a failed sign up request' do
            sign_up_user 'm@a', 'helloWORLD', 'HELLOworld', works: false
          end
        end

        context 'with a wrong email and same passwords' do
          it_behaves_like 'a failed sign up request' do
            before { pending('should fail, enforce better validation for email in User model') }
            sign_up_user 'm@a', 'helloWORLD', 'helloWORLD', works: false
          end
        end

        context 'with a right email and different passwords' do
          it_behaves_like 'a failed sign up request' do
            sign_up_user 'm@getautomata.com', 'helloWORLD', 'HELLOworld', works: false
          end
        end

        context 'with a already used email and different passwords' do
          it_behaves_like 'a failed sign up request' do
            sign_up_user 'ar@getautomata.com', 'helloWORLD', 'HELLOworld', works: false
          end
        end

        context 'with a right email and same passwords (too short)' do
          it_behaves_like 'a failed sign up request' do
            sign_up_user 'm@getautomata.com', 'adam', 'adam', works: false
          end
        end
      end

      context 'with right informations' do
        it_behaves_like 'a successful sign up request' do
          sign_up_user 'm@getautomata.com', 'helloWORLD', 'helloWORLD', works: true
          let (:test_user) { FakeUser.new('m@getautomata.com') }
        end
      end
    end


    context 'when signed in' do
      login_user

      context 'with missing informations' do
        context 'with no information' do
          it_behaves_like 'a already signed in request' do
            sign_up_user '', '', '', works: false
          end
        end

        context 'with an email and no passwords' do
          it_behaves_like 'a already signed in request' do
            sign_up_user 'm@getautomata.com', '', '', works: false
          end
        end

        context 'with an email and one password' do
          it_behaves_like 'a already signed in request' do
            sign_up_user 'm@getautomata.com', 'helloWORLD', '', works: false
          end
        end

        context 'with no email and two passwords' do
          it_behaves_like 'a already signed in request' do
            sign_up_user '', 'helloWORLD', 'helloWORLD', works: false
          end
        end
      end

      context 'with wrong informations' do
        context 'with a wrong email and different passwords' do
          it_behaves_like 'a already signed in request' do
            sign_up_user 'm@a', 'helloWORLD', 'HELLOworld', works: false
          end
        end

        context 'with a wrong email and same passwords' do
          it_behaves_like 'a already signed in request' do
            sign_up_user 'm@a', 'helloWORLD', 'helloWORLD', works: false
          end
        end

        context 'with a right email and different passwords' do
          it_behaves_like 'a already signed in request' do
            sign_up_user 'm@getautomata.com', 'helloWORLD', 'HELLOworld', works: false
          end
        end

        context 'with a already used email and different passwords' do
          it_behaves_like 'a already signed in request' do
            sign_up_user 'ar@getautomata.com', 'helloWORLD', 'HELLOworld', works: false
          end
        end

        context 'with a right email and same passwords (too short)' do
          it_behaves_like 'a already signed in request' do
            sign_up_user 'm@getautomata.com', 'adam', 'adam', works: false
          end
        end
      end

      context 'with right informations' do
        it_behaves_like 'a already signed in request' do
          sign_up_user 'm@getautomata.com', 'helloWORLD', 'helloWORLD', works: false
        end
      end
    end

  end

  describe '#update' do

    context 'when not signed in' do
      create_user(true)
      create_user2(true)

      context 'with missing informations' do
        context 'with no information' do
          it_behaves_like 'a need to sign in request' do
            edit_user '', '', '', '', works: false
          end
        end

        context 'with an email and no passwords' do
          it_behaves_like 'a need to sign in request' do
            edit_user 'm@getautomata.com', '', '', '', works: false
          end
        end

        context 'with an email and one password' do
          it_behaves_like 'a need to sign in request' do
            edit_user 'm@getautomata.com', '', 'helloWORLD', '', works: false
          end
        end

        context 'with an email and two passwords' do
          it_behaves_like 'a need to sign in request' do
            edit_user 'm@getautomata.com', '', 'helloWORLD', 'helloWORLD', works: false
          end
        end

        context 'with no email and two password' do
          it_behaves_like 'a need to sign in request' do
            edit_user '', 'helloworld182', 'helloWORLD', '', works: false
          end
        end

        context 'with no email and three password' do
          it_behaves_like 'a need to sign in request' do
            edit_user '', 'helloworld182', 'helloWORLD', 'helloWORLD', works: false
          end
        end
      end

      context 'with wrong informations' do
        context 'with a wrong email and different passwords' do
          it_behaves_like 'a need to sign in request' do
            edit_user 'm@a', 'helloworld182', 'HELLOworld', 'helloWORLD', works: false
          end
        end

        context 'with a wrong email and same passwords' do
          it_behaves_like 'a need to sign in request' do
            edit_user 'm@a', 'helloworld182', 'helloWORLD', 'helloWORLD', works: false
          end
        end

        context 'with a wrong email and no passwords (just current one)' do
          it_behaves_like 'a need to sign in request' do
            edit_user 'm@a', 'helloworld182', '', '', works: false
          end
        end

        context 'with a right email and different passwords' do
          it_behaves_like 'a need to sign in request' do
            edit_user 'm@getautomata.com', 'helloworld182', 'helloWORLD', 'HELLOworld', works: false
          end
        end

        context 'with a already used email and different passwords' do
          it_behaves_like 'a need to sign in request' do
            edit_user 'lb@getautomata.com', 'helloworld182', 'helloWORLD', 'HELLOworld', works: false
          end
        end

        context 'with a already used email and same passwords' do
          it_behaves_like 'a need to sign in request' do
            edit_user 'lb@getautomata.com', 'helloworld182', 'helloWORLD', 'helloWORLD', works: false
          end
        end

        context 'with a right email and same passwords (too short)' do
          it_behaves_like 'a need to sign in request' do
            edit_user 'm@getautomata.com', 'helloworld182', 'adam', 'adam', works: false
          end
        end

        context 'with a right email and same passwords (current one wrong)' do
          it_behaves_like 'a need to sign in request' do
            edit_user 'm@getautomata.com', 'secretPASS', 'helloWORLD', 'helloWORLD', works: false
          end
        end
      end

      context 'with right informations' do
        context 'with email and passwords' do
          it_behaves_like 'a need to sign in request' do
            edit_user 'm@getautomata.com', 'helloworld182', 'helloWORLD', 'helloWORLD', works: false
          end
        end

        context 'with only email' do
          it_behaves_like 'a need to sign in request' do
            edit_user 'm@getautomata.com', 'helloworld182', '', '', works: false
          end
        end
      end
    end


    context 'when signed in' do
      login_user
      create_user2(true)

      context 'with missing informations' do
        context 'with no information' do
          it_behaves_like 'a failed user edit request' do
            edit_user '', '', '', '', works: false
          end
        end

        context 'with an email and no passwords' do
          it_behaves_like 'a failed user edit request' do
            edit_user 'm@getautomata.com', '', '', '', works: false
          end
        end

        context 'with an email and one password' do
          it_behaves_like 'a failed user edit request' do
            edit_user 'm@getautomata.com', '', 'helloWORLD', '', works: false
          end
        end

        context 'with an email and two passwords' do
          it_behaves_like 'a failed user edit request' do
            edit_user 'm@getautomata.com', '', 'helloWORLD', 'helloWORLD', works: false
          end
        end

        context 'with no email and two password' do
          it_behaves_like 'a failed user edit request' do
            edit_user '', 'helloworld182', 'helloWORLD', '', works: false
          end
        end

        context 'with no email and three password' do
          it_behaves_like 'a failed user edit request' do
            edit_user '', 'helloworld182', 'helloWORLD', 'helloWORLD', works: false
          end
        end
      end

      context 'with wrong informations' do
        context 'with a wrong email and different passwords' do
          it_behaves_like 'a failed user edit request' do
            edit_user 'm@a', 'helloworld182', 'HELLOworld', 'helloWORLD', works: false
          end
        end

        context 'with a wrong email and same passwords' do
          it_behaves_like 'a failed user edit request' do
            make_pending('should fail, enforce better validation for email in User model', true)
            edit_user 'm@a', 'helloworld182', 'helloWORLD', 'helloWORLD', works: false
          end
        end

        context 'with a wrong email and no passwords (just current one)' do
          it_behaves_like 'a failed user edit request' do
            make_pending('should fail, enforce better validation for email in User model', true)
            edit_user 'm@a', 'helloworld182', '', '', works: false
          end
        end

        context 'with a right email and different passwords' do
          it_behaves_like 'a failed user edit request' do
            edit_user 'm@getautomata.com', 'helloworld182', 'helloWORLD', 'HELLOworld', works: false
          end
        end

        context 'with a already used email and different passwords' do
          it_behaves_like 'a failed user edit request' do
            edit_user 'lb@getautomata.com', 'helloworld182', 'helloWORLD', 'HELLOworld', works: false
          end
        end

        context 'with a already used email and same passwords' do
          it_behaves_like 'a failed user edit request' do
            edit_user 'lb@getautomata.com', 'helloworld182', 'helloWORLD', 'helloWORLD', works: false
          end
        end

        context 'with a right email and same passwords (too short)' do
          it_behaves_like 'a failed user edit request' do
            edit_user 'm@getautomata.com', 'helloworld182', 'adam', 'adam', works: false
          end
        end

        context 'with a right email and same passwords (current one wrong)' do
          it_behaves_like 'a failed user edit request' do
            edit_user 'm@getautomata.com', 'secretPASS', 'helloWORLD', 'helloWORLD', works: false
          end
        end
      end

      context 'with right informations' do
        context 'with email and passwords' do
          it_behaves_like 'a successful user edit request' do
            edit_user 'm@getautomata.com', 'helloworld182', 'helloWORLD', 'helloWORLD', works: true
          end
        end

        context 'with only email' do
          it_behaves_like 'a successful user edit request' do
            edit_user 'm@getautomata.com', 'helloworld182', '', '', works: true
          end
        end
      end
    end

  end

  describe '#destroy' do

    context 'when not signed in' do
      create_user(true)
      delete_user(works: false)

      it_behaves_like 'a need to sign in request'
    end


    context 'when signed in' do
      login_user
      delete_user(works: true)

      it_behaves_like 'a redirected request', :root_path
      it_behaves_like 'a request with a flash', :notice, 'Bye! Your account has been successfully cancelled. We hope to see you again soon.'
    end

  end

  describe '#add_token' do

    context 'when not signed in' do
      create_token

      it_behaves_like 'a need to sign in request'
    end


    context 'when signed in' do
      login_user

      context 'when creating one' do
        create_token

        check_tokens_number 1

        it_behaves_like 'a redirected request', :edit_user_registration_path
      end

      context 'when creating five' do
        5.times do
          create_token
        end

        check_tokens_number 5

        it_behaves_like 'a redirected request', :edit_user_registration_path
      end
    end

  end

  describe '#remove_token' do

    context 'when not signed in' do
      delete_a_token

      it_behaves_like 'a need to sign in request'
    end


    context 'when signed in' do
      login_user

      context 'when deleting one' do
        create_token
        delete_a_token

        check_tokens_number 0

        it_behaves_like 'a redirected request', :edit_user_registration_path
      end

      context 'when deleting three' do
        5.times do
          create_token
        end

        3.times do
          delete_a_token
        end

        check_tokens_number 2

        it_behaves_like 'a redirected request', :edit_user_registration_path
      end

      context 'when deleting a undefined token' do
        make_pending('should have error handling')
        delete_a_token

        check_tokens_number 0

        it_behaves_like 'a not found request'
      end

    end

  end
end

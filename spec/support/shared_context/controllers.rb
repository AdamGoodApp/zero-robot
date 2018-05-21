# Basic
shared_context 'a redirected request' do |redirect_path|
  it "has a redirect status and redirect to #{redirect_path}" do
    expect(response).to_not be_success
    expect(response).to be_redirect
    expect(response).to have_http_status(:redirect)
    expect(response).to redirect_to(send(redirect_path))
  end
end

shared_context 'a successful request' do
  it 'has a success status' do
    expect(response).to be_success
    expect(response).to_not be_redirect
    expect(response).to have_http_status(200)
  end
end

shared_context 'a not found request' do
  it 'has a not found status' do
    expect(response).to_not be_success
    expect(response).to_not be_redirect
    expect(response).to have_http_status(404)
  end

  it_behaves_like 'a request with a flash', :alert, 'not found'
end

shared_context 'a request with a flash' do |type, message|
  it "has a #{type} flash" do
    expect(flash[type]).to be_present
    expect(flash[type]).to match(message)
  end
end

# Rendering
shared_context 'a successful rendering' do |view|
  it_behaves_like 'a successful request'

  it "renders the #{view} view" do
    expect(response).to render_template(view)
  end
end

# Users
shared_context 'a logged in request' do |comp|
  it 'should have a current_user' do
    if comp == :not_nil
      expect(subject.current_user.email).to_not eq nil
    else
      expect(subject.current_user.email).to eq test_user.email
    end
  end
end

shared_context 'a logged out request' do
  it 'should not have a current_user' do
    expect(subject.current_user).to eq nil
  end
end

shared_context 'a access denied request' do |message|
  it_behaves_like 'a redirected request', :root_path
  it_behaves_like 'a request with a flash', :alert, message
end

# Login

shared_context 'a need to sign in request' do
  it_behaves_like 'a logged out request'
  it_behaves_like 'a redirected request', :new_user_session_path
  it_behaves_like 'a request with a flash', :alert, 'You need to sign in or sign up before continuing.'
end

shared_context 'a already signed in request' do
  it_behaves_like 'a logged in request', :not_nil
  it_behaves_like 'a redirected request', :root_path
  it_behaves_like 'a request with a flash', :alert, 'You are already signed in.'
end

shared_context 'a successful sign in request' do
  it_behaves_like 'a logged in request', :test_user
  it_behaves_like 'a redirected request', :root_path
  it_behaves_like 'a request with a flash', :notice, 'Signed in successfully.'
end

shared_context 'a failed sign in request' do
  it_behaves_like 'a logged out request'
  it_behaves_like 'a successful rendering', 'devise/sessions/new'
  it_behaves_like 'a request with a flash', :alert, 'Invalid Email or password.'
end

shared_context 'a successful sign up request' do
  it_behaves_like 'a logged in request', :test_user
  it_behaves_like 'a redirected request', :root_path
  it_behaves_like 'a request with a flash', :notice, 'Welcome! You have signed up successfully.'
end

shared_context 'a failed sign up request' do
  it_behaves_like 'a logged out request'
  it_behaves_like 'a successful rendering', 'devise/registrations/new'
end

shared_context 'a successful user edit request' do
  it_behaves_like 'a logged in request', :not_nil
  it_behaves_like 'a redirected request', :root_path
  it_behaves_like 'a request with a flash', :notice, 'Your account has been updated successfully.'
end

shared_context 'a failed user edit request' do
  it_behaves_like 'a logged in request', :not_nil
  it_behaves_like 'a successful rendering', 'devise/registrations/new'
end

shared_context 'a successful sign out request' do
  it_behaves_like 'a logged out request'
  it_behaves_like 'a redirected request', :root_path
  it_behaves_like 'a request with a flash', :notice, 'Signed out successfully.'
end

shared_context 'a successful forgot password request' do
  it_behaves_like 'a logged out request'
  it_behaves_like 'a redirected request', :new_user_session_path
  it_behaves_like 'a request with a flash', :notice, 'You will receive an email with instructions on how to reset your password in a few minutes.'
end

shared_context 'a successful reset password request' do
  it_behaves_like 'a logged in request', :test_user
  it_behaves_like 'a redirected request', :root_path
  it_behaves_like 'a request with a flash', :notice, 'Your password has been changed successfully. You are now signed in.'
end

shared_context 'a failed reset password request' do
  it_behaves_like 'a logged out request'
  it_behaves_like 'a successful rendering', 'devise/passwords/edit'
end

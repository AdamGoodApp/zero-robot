describe 'devise/mailer/reset_password_instructions.html.erb' do

  context 'when rendered' do
    create_user(true)
    setup_devise
    before (:each) do
      @resource = @user
      @token = 'hello'
    end

    it 'has the correct reset link' do
      render
      expect(rendered).to include(edit_user_password_url(reset_password_token: 'hello'))
    end
  end
end
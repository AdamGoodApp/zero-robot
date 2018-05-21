describe ApplicationController do
  make_private_public(ApplicationController)

  # describe '#setup' do
  #   context 'when not signed in' do # TODO: finish
  #     it_behaves_like 'a logged out request'
  #     it_behaves_like 'a successful rendering', 'setup'
  #   end
  # end

  describe '#user' do
    context 'when not signed in' do
      it_behaves_like 'a logged out request'
    end

    context 'when signed in' do
      login_user

      it_behaves_like 'a logged in request' do
        let (:test_user) { user }
      end
    end
  end

end

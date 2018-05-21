describe 'shared/_messages.html.erb' do
  # Devise flashes
  it_behaves_like 'a view with a flash', :alert, 'Alert Flash!'
  it_behaves_like 'a view with a flash', :notice, 'Notice Flash.'

  # Our flashes (bootstrap-inspired)
  it_behaves_like 'a view with a flash', :success, 'Success Flash!'
  it_behaves_like 'a view with a flash', :info, 'Info Flash.'
  it_behaves_like 'a view with a flash', :warning, 'Warning Flash?'
  it_behaves_like 'a view with a flash', :error, 'Error Flash.'
end
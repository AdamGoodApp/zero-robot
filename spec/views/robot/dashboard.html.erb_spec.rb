describe 'robot/dashboard.html.erb', ssr: true do
  login_user
  fetch_robot
  before(:each) do
    @view_config = {
    }
    @should_prerender = true
  end

  # TODO: finish
end

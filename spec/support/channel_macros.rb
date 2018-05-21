module ChannelMacros
  def setup_request
    before (:each) do
      @request = ActionController::TestRequest.create
    end
  end

  def setup_env
    let (:env) { {'REQUEST_METHOD' => 'GET', 'HTTP_CONNECTION' => 'upgrade', 'HTTP_UPGRADE' => 'websocket'} }
  end

  def setup_server
    let (:server) { ActionCable::Server::Base.new }
  end

  def setup_connection
    setup_env
    setup_server

    let (:connection) { ApplicationCable::Connection.new(server, env) }
  end
end

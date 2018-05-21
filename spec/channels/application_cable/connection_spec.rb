def create_connection
  subject {
    connection = ApplicationCable::Connection.new(server, env)
    allow(connection).to receive(:request).and_return(@request)
    connection
  }
end

def assign_user(user_r = nil)
  before (:each) do
    jar = double("jar")
    allow(jar).to receive(:signed).and_return({user_id: (user_r.nil? ? user.id : user_r)})
    allow(@request).to receive(:cookie_jar).and_return(jar)
  end
  create_connection
end

shared_context 'a successful connection' do
  it 'assigns the user' do
    expect(subject).not_to receive(:reject_unauthorized_connection)
    subject.connect
    expect(subject.current_user).to eq(user)
  end
end

shared_context 'a rejected connection' do
  it 'rejects the connection' do
    expect(subject).to receive(:reject_unauthorized_connection).with(no_args)
    subject.connect
    expect(subject.current_user).to eq(nil)
  end
end

describe ApplicationCable::Connection, type: :channel do
  setup_request
  setup_env
  setup_server

  create_user

  describe '.connect' do
    context 'when using Front-End authentication' do
      context 'with a correct user' do
        assign_user
        it_behaves_like 'a successful connection'
      end

      context 'with an invalid user' do
        assign_user(123)
        it_behaves_like 'a rejected connection'
      end
    end

    context 'with nothing' do
      create_connection
      it_behaves_like 'a rejected connection'
    end
  end
end

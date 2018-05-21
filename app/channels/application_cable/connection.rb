module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_user
    end

    private

    def find_user
      begin
        if current_user = User.find_by(id: cookies.signed[:user_id])
          return current_user
        end
        # Invalid
      rescue
        # Invalid
      end
      reject_unauthorized_connection
    end
  end
end

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      params = request.headers

      access_token = params["access-token"]
      uid = params["uid"]
      client = params["client"]

      self.current_user = find_verified_user access_token, uid, client
    end

    private
      def find_verified_user(token, uid, client_id)
        user = User.find_by uid: uid
        if user && user.valid_token?(token, client_id)
          user
        else
          reject_unauthorized_connection
        end
      end
  end
end

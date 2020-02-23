module ApplicationCable
  # Application Websocket connection
  class Connection < ActionCable::Connection::Base
    identified_by :current_auth_extension

    # Lookup +current_auth_extension+ and configure logger
    # @return nil
    def connect
      self.current_auth_extension = find_current_auth_extension!
      logger.add_tags 'ActionCable', current_auth_extension.email
    end

    private

    # Lookup +current_auth_extension+ and reject conections when invalid
    # @return nil
    def find_current_auth_extension!
      uid = request.params['uid']
      token = request.params['access-token']
      client = request.params['client']

      extension = Extension.find_by uid: uid

      if extension && extension&.valid_token?(token, client)
        extension
      else
        reject_unauthorized_connection
      end
    end
  end
end

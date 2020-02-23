module Requests
  module AuthHelpers
    module Extensions
      # This will make a login in test suite, but first we must know whos makes
      # login request
      # @param object - Extension, user or company api
      # @return nil
      def sign_in(object)
        let(:auth_helpers_auth_token) do
          if object == :extension
            public_send(object).create_new_auth_token
          elsif object == :user
            public_send(object).create_new_auth_token
          else
            {
              'Authorization' => ['Bearer',
                public_send(object).api_key].join(' ')
            }
          end
        end
      end
    end

    module Includables
      HTTP_HELPERS_TO_OVERRIDE = %i[get post patch put delete].freeze
      # Override helpers for Rails 5.0
      # see http://api.rubyonrails.org/v5.0/classes/ActionDispatch/Integration/RequestHelpers.html
      HTTP_HELPERS_TO_OVERRIDE.each do |helper|
        define_method(helper) do |path, **args|
          add_auth_headers(args)
          args == {} ? super(path) : super(path, **args)
        end
      end

      private

      def add_auth_headers(args)
        return unless defined? auth_helpers_auth_token
        args[:headers] ||= {}
        args[:headers].merge!(auth_helpers_auth_token)
      end
    end
  end
end

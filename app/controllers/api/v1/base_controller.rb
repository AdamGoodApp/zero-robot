module Api
  module V1
    # TODO: should probably not use the website controller
    # class BaseController < ActionController::Base
    class BaseController < ApplicationController
      skip_before_action  :verify_authenticity_token
      before_action :restrict_access

      respond_to :json

      private

      def restrict_access
        unless @user
          authenticate_or_request_with_http_token do |token, options|
            ApiKey.exists?(access_token: token)
          end
        end
      end

    end
  end
end

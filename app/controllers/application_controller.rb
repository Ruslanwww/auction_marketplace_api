class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include DeviseWhitelist
  include Pundit

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: { error: exception.message }, status: :not_found
  end

  rescue_from Pundit::NotAuthorizedError do
    render json: { error: "You are not have permission for this action" }, status: :unauthorized
  end
end

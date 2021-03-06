module ControllerSpecHelper
  def json
    JSON.parse(response.body, symbolize_names: true)
  end

  def login_by(user)
    sign_in user
    request.headers.merge! user.create_new_auth_token
  end
end

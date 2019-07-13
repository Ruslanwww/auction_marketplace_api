module ControllerMacros
  def login(user, params = {})
    before(:each) do
      @user = create(user, params)
      sign_in @user
      request.headers.merge! @user.create_new_auth_token
    end
  end
end

class SessionsController < ApplicationController
  def create
    user = User.find_by(username: session_params[:username])

    if user&.authenticate(session_params[:password])
      token = JwtService.encode(user_id: user.id)
      render json: { token: token, user: { id: user.id, username: user.username } }, status: :ok
    else
      render json: { error: "Invalid username or password" }, status: :unauthorized
    end
  end

  private

  def session_params
    params.require(:user).permit(:username, :password)
  end
end

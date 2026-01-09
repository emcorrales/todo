module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  private

  def authenticate_user!
    token = extract_token
    return render json: { error: "Missing or invalid token" }, status: :unauthorized unless token

    decoded = JwtService.decode(token)
    return render json: { error: "Invalid token" }, status: :unauthorized unless decoded

    @current_user = User.find_by(id: decoded["user_id"])
    return render json: { error: "User not found" }, status: :unauthorized unless @current_user
  end

  def current_user
    @current_user
  end

  def extract_token
    authorization_header = request.headers["Authorization"]
    return nil unless authorization_header

    authorization_header.split(" ").last if authorization_header.start_with?("Bearer ")
  end
end

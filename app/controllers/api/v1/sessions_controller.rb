class Api::V1::SessionsController < Devise::SessionsController
  respond_to :json
  skip_before_action :verify_signed_out_user # Prevent Devise from throwing if no session exists

  def create
    user = User.find_for_database_authentication(email: login_params[:email])

    if user && user.valid_password?(login_params[:password])
      sign_in(user, store: false) # This is OK — Devise-JWT hooks into this to issue a token
      respond_with(user)
    else
      render json: {
        status: { code: 401, message: 'Invalid email or password.' }
      }, status: :unauthorized
    end
  end

  private

  def login_params
    params.require(:data).require(:attributes).permit(:email, :password)
  end

  def respond_with(resource, _opts = {})
    token = Warden::JWTAuth::UserEncoder.new.call(resource, :user, nil).first

    render json: {
      status: { code: 200, message: "Logged in successfully." },
      data: UserSerializer.new(resource).serializable_hash[:data][:attributes],
      token: token
    }, status: :ok
  end

  def respond_to_on_destroy
    if request.headers["Authorization"].present?
      jwt_payload = JWT.decode(
        request.headers["Authorization"].split(" ").last,
        Rails.application.credentials.devise_jwt_secret_key || ENV["DEVISE_JWT_SECRET_KEY"]
      ).first

      current_user = User.find(jwt_payload["sub"])
    end

    if current_user
      render json: {
        status: 200,
        message: "Logged out successfully."
      }, status: :ok
    else
      render json: {
        status: 401,
        message: "Couldn't find an active session or token."
      }, status: :unauthorized
    end
  end
end

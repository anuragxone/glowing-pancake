# app/controllers/api/v1/registrations_controller.rb
class Api::V1::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    build_resource(sign_up_params)

    if resource.save
      # sign_up(resource_name, resource)
      respond_with(resource)
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with(resource)
    end
  end

  private

  def sign_up_params
    # expects JSON:API format
    # request.body.read
    params.expect(user: [ :name, :email, :password, :password_confirmation ])
  end

  def respond_with(resource, _opts = {})
    if resource.persisted?
      # token = Warden::JWTAuth::UserEncoder.new.call(resource, :user, nil)[0]
      data = UserSerializer.new(resource).serializable_hash[:data][:attributes]

      render json: {
        # status: { code: 200, message: 'Signed up successfully.' },
        data: data
        # token: token
      }, status: :ok
    else
      render json: {
        status: {
          code: 422,
          message: "User couldn't be created successfully. #{resource.errors.full_messages.join(', ')}"
        }
      }, status: :unprocessable_entity
    end
  end
end

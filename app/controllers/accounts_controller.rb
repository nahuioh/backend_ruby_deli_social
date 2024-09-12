class AccountsController < ApplicationController
  require "mailgun-ruby"

  # Servicio JWT para generar el token
  require "jwt"

  def create
    respond_to do |format|
      format.json do
        account = Account.find_or_initialize_by(email: account_params[:email])

        if account.new_record?
          account.assign_attributes(account_params)

          if account.save
            # Generar un token JWT
            token = JsonWebToken.encode({ user_id: account.id })

            if send_confirmation_email(account.email, account.nombreUsuario)
              render json: { token: token, message: "Cuenta creada exitosamente. Revisa tu correo para confirmar tu cuenta." }, status: :created
            else
              Rails.logger.error "Fallo al enviar correo de confirmación #{account.email}"
              render json: { errors: "Unicamente acepta correo nahuel.alm@outlook, por la cuenta free de mailgun!, osea error al enviar correo!" }, status: :unprocessable_entity
            end
          else
            Rails.logger.error "Fallo al guardar la cuenta: #{account.errors.full_messages}"
            render json: { errors: account.errors.full_messages }, status: :unprocessable_entity
          end
        else
          # La cuenta ya existe, por lo que respondemos con 409 Conflict
          Rails.logger.info "La cuenta con el email #{account.email} ya existe."
          render json: { errors: "La cuenta ya existe." }, status: :conflict
        end
      end
    end
  end

  private

  def account_params
    params.require(:account).permit(:email, :nombreCompleto, :age, :nombreUsuario, :country, :password)
  end

  def send_confirmation_email(email, nombreUsuario)
    begin
      Rails.logger.info "Sending confirmation email to #{email}"

      # URL y parámetros del mensaje
      url = "https://api.mailgun.net/v3/sandbox33a0f8b55bc747c8a325c45e5ef904ed.mailgun.org/messages"
      message_params = {
        from: "Mailgun Sandbox <postmaster@sandbox33a0f8b55bc747c8a325c45e5ef904ed.mailgun.org>",
        to: email,
        subject: "Confirmación de tu cuenta",
        template: "newsletter deli social", # Usar la plantilla
        "h:X-Mailgun-Variables": { user_name: nombreUsuario }.to_json
      }

      # Enviar el correo usando RestClient con autenticación básica
      response = RestClient.post(
        url,
        message_params,
        { Authorization: "Basic #{Base64.strict_encode64("api:1c8c6c8f669eca7d47810a0711ca820f-826eddfb-2ae27017")}" }
      )

      Rails.logger.info "Mailgun response: #{response.body}"
      true
    rescue RestClient::ExceptionWithResponse => e
      Rails.logger.error "Failed to send confirmation email: #{e.response.body}"
      false
    rescue StandardError => e
      Rails.logger.error "Failed to send confirmation email: #{e.message}"
      false
    end
  end
end

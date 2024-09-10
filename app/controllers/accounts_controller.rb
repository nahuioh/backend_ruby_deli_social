class AccountsController < ApplicationController
  require "mailgun-ruby"

  def create
    account = Account.find_or_initialize_by(email: account_params[:email])

    if account.new_record?
      account.assign_attributes(account_params)

      if account.save
        token = SecureRandom.hex(10)  # Generar un token

        if send_confirmation_email(account.email, account.nombreUsuario)
          render json: { token: token, message: "Cuenta creada exitosamente. Revisa tu correo para confirmar tu cuenta." }, status: :created
        else
          Rails.logger.error "Fallo al enviar correo de confirmación #{account.email}"
          render json: { errors: [ "Failed to send confirmation email." ] }, status: :unprocessable_entity
        end
      else
        Rails.logger.error "Fallo al guardar la cuenta: #{account.errors.full_messages}"
        render json: { errors: account.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { message: "La cuenta ya existe." }, status: :conflict
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
      url = "https://api.mailgun.net/v3/sandboxdc6218c1de094f4a95a428aade4e48e3.mailgun.org/messages"
      message_params = {
        from: "Mailgun Sandbox <postmaster@sandboxdc6218c1de094f4a95a428aade4e48e3.mailgun.org>",
        to: email,
        subject: "Confirmación de tu cuenta",
        template: "deli newsletter register", # Usar la plantilla
        "h:X-Mailgun-Variables": { user_name: nombreUsuario }.to_json
      }

      # Enviar el correo usando RestClient con autenticación básica
      response = RestClient.post(
        url,
        message_params,
        { Authorization: "Basic #{Base64.strict_encode64("api:9b45f411ac77492bbdb1ca3cfc41fcd0-826eddfb-c3fd5122")}" }
      )

      Rails.logger.info "Mailgun response: #{response.body}"
      true
    rescue RestClient::ExceptionWithResponse => e
      Rails.logger.error "Failed to send confirmation email: #{e.response}"
      false
    rescue StandardError => e
      Rails.logger.error "Failed to send confirmation email: #{e.message}"
      false
    end
  end
end

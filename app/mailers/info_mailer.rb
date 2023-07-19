class InfoMailer < ApplicationMailer
  def send_invitation_email(email, passcode)
    @email = email
    @passcode = passcode
    mail( 
      to: email,
      subject: "#{ENV["SERVICE_NAME"]}の管理者へのご招待"
    )
  end
end

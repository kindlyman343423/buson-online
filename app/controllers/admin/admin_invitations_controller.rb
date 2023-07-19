class Admin::AdminInvitationsController < Admin::ApplicationController
  before_action :authenticate_account_is_owner, only: [:create]

  # Eメールを受け取り、パスコードを載せたメールを送る
  # すでにAuthCode作成済みの場合は上書き
  # POST /admin/admin_invitations
  def create
    # TODO emailからfirebase_uidを取得して、そのuidがaccountsテーブルに存在し、管理者ロールがついていないかを確認する

    email = params[:email]
    invitation = AdminInvitation.find_or_initialize_by(email: email)
    invitation.passcode = SecureRandom.base64(10)
    invitation.save!
    InfoMailer.send_invitation_email(email, invitation.passcode).deliver_now
    head :ok
  end

  private
end
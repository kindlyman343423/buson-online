class AccountsController < ApplicationController
  skip_before_action :authenticate_account, only: [:create, :confirm]

  # POST /account
  def create
    # sub: IDトークンのsubject(件名)、IDトークンの値
    if Account.find_by(firebase_uid: auth_payload['sub']).present?
      render json: ['アカウントはすでに登録済みです'], status: :conflict 
      return
    end

    account = Account.new(account_params.merge(firebase_uid: auth_payload['sub']))
    if account.invalid?
      render json: account.errors.full_messages, status: :unprocessable_entity
      return
    end

    if account.save
      # 無料登録と同時にStripeでCustomerを作る
      stripe_client = StripeClient.new
      customer = stripe_client.create_customer(id: account.id)
      account.update!(stripe_customer_id: customer.id)

      render json: { account_id: account.id }, status: :ok
    else
      render json: account.errors.full_messages, status: :unprocessable_entity
    end
  end

  # GET /account
  def show
    data = current_account.attributes.slice('last_name', 'first_name', 'last_name_kana', 'first_name_kana')
    render json: { account: data }, status: :ok
  end

  # PATCH /account
  def update
    if current_account.update(account_params)
      head :ok
    else
      render json: current_account.errors.full_messages, status: :unprocessable_entity
    end
  end

  # DELETE /account
  # def destroy
  #   current_account.destroy!
  #   # Stripe customer削除
  #   # firebase user削除
  #   head :ok
  # end

  # DBに登録されているかどうか、有料会員かをチェック
  # GET /account/confirm
  def confirm
    logger.info("######## confirm")
    account = Account.find_by(firebase_uid: auth_payload['sub'])
    data = {}

    if account.present?
      data[:account_id] = account.id

      if account.role == "owner" || account.role == "editor"
        data[:role] = account.role
      end

      if account.stripe_subscription_id.present?
        stripe_client = StripeClient.new
        # stripe_subscription_idがactiveかどうかをチェックする
        if stripe_client.check_subscription_is_active(subscription_id: current_account.stripe_subscription_id)
          data[:is_paid] = true
        else
          # stripe_subscription_idがactiveでない場合は、DBも更新
          current_account.update_attribute(:stripe_subscription_id, nil)
          data[:is_paid] = false
        end
      else
        # 無料会員確定
        data[:is_paid] = false
      end
    end
    
    render json: data, status: :ok
  end

  # 認証コードを入力して、編集者にロールを変える
  # POST /account/register_as_admin
  def register_as_admin
    passcode = params[:passcode]
    return render json: ['入力が正しくありません'], status: :not_found if passcode.blank?

    service_account = FirebaseAuth::ServiceAccount.new
    firebase_user = service_account.get_user(uid: current_account.firebase_uid)

    invitation = AdminInvitation.find_by(passcode: passcode, email: firebase_user.email)
    return render json: ['入力が正しくありません'], status: :not_found unless invitation.present?

    # 24時間で期限切れ
    if invitation.created_at < Time.current - 24.hours
      invitation.destroy!
      return render json: ['認証コードの期限が過ぎております。再度発行を依頼してください。'], status: :forbidden
    end

    current_account.update!(role: "editor")
    invitation.destroy!
    render json: { role: "editor" }, status: :ok
  end

  # PATCH /account/cancel_subscription
  def cancel_subscription
    stripe_client = StripeClient.new
    stripe_client.cancel_subscription(subscription_id: current_account.stripe_subscription_id)

    head :ok
  end

  private

  def account_params
    params.require(:account).permit(:last_name, :first_name, :last_name_kana, :first_name_kana)
  end
end

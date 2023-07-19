class Admin::AccountsController < Admin::ApplicationController
  before_action :set_account, only: [:cancel_subscription]

  # GET /admin/accounts
  def index
    accounts = Account.order(created_at: "ASC").page(params[:page] || 1).per(30)

    # firebase authからメール一覧を取得する
    firebase_uids = accounts.map{ |account| account.firebase_uid }
    service_account = FirebaseAuth::ServiceAccount.new
    uid_email_obj = service_account
                    .get_users(uids: firebase_uids)
                    .reduce({}) { |acc, curr| acc.merge("#{curr.local_id}": curr.email) }

    data = {
      total_count: accounts.total_count,
      total_pages: accounts.total_pages,
      current_page: accounts.current_page,
      accounts: accounts.map{ |account| account.detail_format.merge!(email: uid_email_obj[account.firebase_uid.to_sym] ) }
    }

    render json: data, status: :ok
  end

  # PATCH /admin/accounts/1/cancel_subscription
  def cancel_subscription
    stripe_client = StripeClient.new
    stripe_client.cancel_subscription(subscription_id: @account.stripe_subscription_id)

    head :ok
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end
end
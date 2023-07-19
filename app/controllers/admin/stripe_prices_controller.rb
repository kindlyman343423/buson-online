class Admin::StripePricesController < Admin::ApplicationController
  before_action :authenticate_account_is_admin

  # GET /admin/stripe_prices/get_latest_price
  def get_latest_price
    stripe_client = StripeClient.new
    default_price_id = stripe_client.get_default_price_id
    price = stripe_client.get_price(stripe_price_id: default_price_id)
    render json: { stripe_price: { amount: price.unit_amount } }, status: :ok
  end

  # POST /admin/stripe_prices
  def create
    # https://stripe.com/docs/products-prices/manage-prices?dashboard-or-api=api#edit-price
    # API では価格の金額を変更できないことに注意してください。代わりに、新たな金額で新しい価格を作成し、その新しい価格の ID に切り替えて、古い価格を更新して無効にすることをお勧めします。
    stripe_client = StripeClient.new
    price = stripe_client.create_price(amount: stripe_price_params[:amount])
    stripe_client.set_default_price(stripe_price_id: price.id) # 最新がデフォルトの料金

    head :ok
  end

  

  private

  def stripe_price_params
    params.require(:stripe_price).permit(:amount)
  end
end
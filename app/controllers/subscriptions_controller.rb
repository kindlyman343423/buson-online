class SubscriptionsController < ApplicationController

  # POST /subscriptions
  def create
    stripe_client = StripeClient.new
    default_price_id = stripe_client.get_default_price_id
    subscription = stripe_client.create_subscription(customer_id: current_account.stripe_customer_id, price_id: default_price_id)
    currnet_account.update!(stripe_subscription_id: subscription.id)
  end
end

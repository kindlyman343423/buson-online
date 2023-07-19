require 'stripe'

# 参考資料: https://stripe.com/docs/api/customers/object?lang=ruby

class StripeClient
  def create_customer(id:)
    # metadataは検索用に必要
    Stripe::Customer.create(description: "id: #{id}", metadata: {
      account_id: id,
    })
  end

  def get_customer(customer_id:)
    Stripe::Customer.retrieve(customer_id)
  end

  # ids: [1,2,3,4...]
  # idsの個数の上限値は100
  def search_customers(ids:)
    return if ids.count > 100

    query = ""
    ids.each_with_index do |id, index|
      query += index == 0 ? "metadata[\'account_id\']:\'#{id}\'" : " OR metadata[\'account_id\']:\'#{id}\'"
    end

    Stripe::Customer.search({ query: query, limit: 100 }) # limitはdefaultで10, 最大100
  end

  # metadataの例：{order_id: '6735'}
  def update_customer(customer_id:,metadata:)
    Stripe::Customer.update(
      customer_id,
      {metadata: metadata},
    )
  end

  def create_price(amount:)
    Stripe::Price.create({
      product: ENV["STRIPE_PRODUCT_ID"],
      unit_amount: amount,
      currency: 'jpy',
      recurring: {interval: 'month'},
    })
  end

  def get_default_price_id
    product = Stripe::Product.retrieve(ENV["STRIPE_PRODUCT_ID"])
    product.default_price # id of default price
  end

  def set_default_price(stripe_price_id:)
    Stripe::Product.update(ENV["STRIPE_PRODUCT_ID"], { default_price: stripe_price_id })
  end

  def get_price(stripe_price_id:)
    Stripe::Price.retrieve(stripe_price_id)
  end
  
  def update_price(stripe_price_id:,metadata:)
    Stripe::Price.update(
      stripe_price_id,
      {metadata: metadata}
    )
  end

  # 1/3に契約した場合、1/15で解約すると、2/2まで使える
  def cancel_subscription(subscription_id:)
    Stripe::Subscription.update(subscription_id, {cancel_at_period_end: true})
  end

  def check_subscription_is_active(subscription_id:)
    return false unless subscription_id.present?
    sub = Stripe::Subscription.retrieve(subscription_id)
    sub.status === "active"
  end

  def create_subscription(customer_id:,price_id:)
    Stripe::Subscription.create({
      customer: customer_id,
      items: [
        {price: price_id},
      ],
    })
  end
end


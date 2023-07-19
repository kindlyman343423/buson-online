# 初期設定

# productは既に作成済み（作ってないならstripeのコンソールから作って、環境変数を設定:STRIPE_PRODUCT_ID）

# 初期planを作る
stripe_client = StripeClient.new
price = stripe_client.create_price(amount: 10)
stripe_client.set_default_price(stripe_price_id: price.id)

# ownerを作る
account = Account.create!(
  last_name: "オーナー田中",
  first_name: "太郎",
  last_name_kana: "タナカ",
  first_name_kana: "タロウ",
  firebase_uid: ENV["TEST_OWNER_FIREBASE_UID"],
  role: "owner"
)
customer = stripe_client.create_customer(id: account.id)
account.update!(stripe_customer_id: customer.id)

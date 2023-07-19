class Account < ApplicationRecord
  enum role: { owner: 0, editor: 10, general: 20 }

  validates :role, presence: true
  validates :firebase_uid, presence: true

  validates :last_name, presence: true
  validates :first_name, presence: true
  validates :last_name_kana, presence: true, format: { with: /\A[\p{katakana}　ー－&&[^ -~｡-ﾟ]]+\z/, message: :only_katakana }
  validates :first_name_kana, presence: true, format: { with: /\A[\p{katakana}　ー－&&[^ -~｡-ﾟ]]+\z/, message: :only_katakana }

  def detail_format
    
    data = {
      id: id,
      last_name: last_name,
      first_name: first_name,
      last_name_kana: last_name_kana,
      first_name_kana: first_name_kana,
    }

    stripe_client = StripeClient.new
    data[:is_paid] = stripe_client.check_subscription_is_active(subscription_id: stripe_subscription_id)

    data
  end

  def admin_format
    data = {
      id: id,
      last_name: last_name,
      first_name: first_name,
      last_name_kana: last_name_kana,
      first_name_kana: first_name_kana,
      role: role,
      created_at: created_at
    }

    # メールリストがあれば、メールを追加する
    # if email_list

    # end

    data
  end
end

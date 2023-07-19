class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.integer :role, null: false, default: 20
      t.string :firebase_uid, null: false, comment: "firebasse auth"
      t.string :last_name, null: false
      t.string :first_name, null: false
      t.string :last_name_kana, null: false
      t.string :first_name_kana, null: false
      t.string :stripe_customer_id
      t.string :stripe_subscription_id

      t.timestamps
    end
  end
end

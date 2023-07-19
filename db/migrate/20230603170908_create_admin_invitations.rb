class CreateAdminInvitations < ActiveRecord::Migration[7.0]
  def change
    create_table :admin_invitations do |t|
      t.string :passcode, null: false
      t.string :email, null: false

      t.timestamps
    end
  end
end

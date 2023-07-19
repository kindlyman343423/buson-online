class AdminInvitation < ApplicationRecord
  validates :email, presence: true
  validates :passcode, presence: true
end

class Admin::AdminStaffsController < Admin::ApplicationController
  before_action :authenticate_account_is_owner, only: [:cancel]
  before_action :set_admin_staff, only: [:cancel]

  # GET /admin/admin_staffs
  def index
    accounts = Account.order(created_at: "ASC").where(role: "owner").or(Account.where(role: 'editor'))

    # firebase authからメール一覧を取得する
    firebase_uids = accounts.map{ |account| account.firebase_uid }
    service_account = FirebaseAuth::ServiceAccount.new
    uid_email_obj = service_account
                    .get_users(uids: firebase_uids)
                    .reduce({}) { |acc, curr| acc.merge("#{curr.local_id}": curr.email) }

    admin_staffs = accounts.map{ |account| account.admin_format.merge!(email: uid_email_obj[account.firebase_uid.to_sym] ) }

    render json: { admin_staffs: admin_staffs }, status: :ok
  end

  # PATCH /admin/admin_staffs/1/cancel
  def cancel
    if @admin_staff.update(role: "general")
      head :ok
    else
      render json: @admin_staff.errors.full_messages, status: :unprocessable_entity
    end
  end

  private

  def set_admin_staff
    @admin_staff = Account.find(params[:id])
  end
end
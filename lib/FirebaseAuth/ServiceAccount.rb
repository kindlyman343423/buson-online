require 'google/apis/identitytoolkit_v3'

# 参考資料: https://www.rubydoc.info/gems/firebase-auth/Firebase/Auth/Client

class FirebaseAuth::ServiceAccount
  def initialize
    @service = Google::Apis::IdentitytoolkitV3::IdentityToolkitService.new
    @service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
      scope: 'https://www.googleapis.com/auth/identitytoolkit'
    )
  end

  def get_user(uid:)
    get_account_info(local_id: [uid])&.users&.first
  end

  # uidsは配列: ["aaaa", "bbbb"]
  # 配列のマックス数はわからないので、あまり多く入れないこと
  def get_users(uids:)
    get_account_info(local_id: uids)&.users
  end

  # 動作確認してない
  # params: { display_name, email, password, email_verified }
  def create_user(params:)
    params = { email_verified: false }.merge(params)
    request = Google::Apis::IdentitytoolkitV3::SignupNewUserRequest.new(params)
    @service.signup_new_user(request)
  end

  # 動作確認してない
  # params: { display_name, email, password }
  def update_user(uid:, params:)
    params = { local_id: uid }.merge(params)
    request = Google::Apis::IdentitytoolkitV3::SetAccountInfoRequest.new(params)
    @service.set_account_info(request)
  end

  # 動作確認してない
  def delete_user(uid:)
    request = Google::Apis::IdentitytoolkitV3::DeleteAccountRequest.new(local_id: uid)
    @service.delete_account(request)
  end

  def get_account_info(local_id:)
    request = Google::Apis::IdentitytoolkitV3::GetAccountInfoRequest.new(local_id: local_id)
    @service.get_account_info(request)
  end
end
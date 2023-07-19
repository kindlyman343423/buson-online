class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include Secured # 全てのリクエストにおいてbefore_actionでfirebaseのトークンのチェックを行う

  before_action :authenticate_account # firebaseトークンチェック後、Accountテーブルに登録されているかの確認をする

  # 他のエラーハンドリングでキャッチできなかった場合に
  # 500 Internal Server Error(システムエラー)を発生させる
  rescue_from Exception, with: :handle_500

  # 500エラーハンドリング処理
  def handle_500(exception = nil)
    logger.fatal "## Rendering 500 with exception: #{exception.message}" if exception
    Sentry.capture_exception(exception) if process.env.NODE_ENV === 'production'
    render json: ['エラーが発生しました'], status: :internal_server_error
  end

  # ヘッダーのアクセストークン情報をもとに、DBにユーザーが登録されているかをチェック
  def authenticate_account
    render json: ['登録されていません'], status: :unauthorized unless current_account.present?
  end

  def current_account
    @current_account ||= Account.find_by(firebase_uid: auth_payload['sub'])
  end
end

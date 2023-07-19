class Admin::ApplicationController < ApplicationController
  before_action :authenticate_account_is_admin

  private 

  def authenticate_account_is_admin
    render json: ['アクセス権がありません'], status: :forbidden unless ["owner", "editor"].include?(current_account.role) 
  end

  def authenticate_account_is_owner
    render json: ['アクセス権がありません'], status: :forbidden unless ["owner"].include?(current_account.role) 
  end
end

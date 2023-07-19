# frozen_string_literal: true

require 'jwt'

module Secured
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
  end

  def auth_payload
    @auth_payload
  end

  private

  def authenticate_request!
    validator = FirebaseAuth::TokenValidator.new(http_token)
    @auth_payload = validator.validate!
  rescue JWT::DecodeError => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join("\n")

    render json: { errors: ['アクセス権限がありません'] }, status: :unauthorized
  end

  def http_token
    return unless request.headers['Authorization'].present?

    request.headers['Authorization'].split(' ').last
  end
end

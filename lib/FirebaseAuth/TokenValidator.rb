# @see https://firebase.google.com/docs/auth/admin/verify-id-tokens?hl=ja
#
# Usage:
#    validator = FirebaseAuth::TokenValidator.new(token)
#    payload = validator.validate!
#

require 'net/http'
require 'uri'

class FirebaseAuth::TokenValidator
  class InvalidTokenError < StandardError; end

  ALG = 'RS256'
  CERTS_URI = 'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com'
  CERTS_CACHE_KEY = 'firebase_auth_certificates'
  FIREBASE_PROJECT_ID = ENV['FIREBASE_PROJECT_ID']
  ISSUER_URI_BASE = 'https://securetoken.google.com/'

  def initialize(token)
    @token = token
  end

  #
  # Validates firebase authentication token
  #
  # @raise [InvalidTokenError] validation error
  # @return [Hash] valid payload
  #
  def validate!
    options = {
      algorithm: ALG,
      iss: ISSUER_URI_BASE + ENV['FIREBASE_PROJECT_ID'],
      verify_iss: true,
      aud: ENV['FIREBASE_PROJECT_ID'],
      verify_aud: true,
      verify_iat: true
    }

    payload, = JWT.decode(@token, nil, true, options) do |header|
      cert = fetch_certificates[header['kid']]
      OpenSSL::X509::Certificate.new(cert).public_key if cert.present?
    end

    # JWT.decode でチェックされない項目のチェック
    raise InvalidTokenError, 'Invalid auth_time' unless Time.zone.at(payload['auth_time']).past?
    raise InvalidTokenError, 'Invalid sub' if payload['sub'].empty?

    payload
  end

  private

  # TODO: Rails.cache(Redis)を導入すること
  # 証明書は毎回取得せずにキャッシュする (要: Rails.cache)
  def fetch_certificates
    # cached = Rails.cache.read(CERTS_CACHE_KEY)
    # return cached if cached.present?

    res = Net::HTTP.get_response(URI(CERTS_URI))
    raise 'Fetch certificates error' unless res.is_a?(Net::HTTPSuccess)

    JSON.parse(res.body)
    # expires_at = Time.zone.parse(res.header['expires'])
    # Rails.cache.write(CERTS_CACHE_KEY, body, expires_in: expires_at - Time.current)
  end
end

# 参考
# https://satococoa.hatenablog.com/entry/2018/10/05/210933
# https://blog.takeyuweb.co.jp/entry/2020/11/10/082536

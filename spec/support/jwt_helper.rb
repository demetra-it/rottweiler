# frozen_string_literal: true

require 'openssl'

class JwtHelper
  class << self
    def encode(payload, ttl: 900)
      payload[:exp] = Time.now.to_i + ttl.to_i
      payload[:ttl] = ttl.to_i
      JWT.encode(payload, private_rsa_key, 'RS256')
    end

    def decode(token)
      body = JWT.decode(token, public_rsa_key, false, algorithm: 'RS256')[0]
      HashWithIndifferentAccess.new body
    rescue StandardError
      nil
    end

    def private_rsa_key
      @private_rsa_key ||= OpenSSL::PKey::RSA.generate 2048
    end

    def public_rsa_key
      @public_rsa_key ||= private_rsa_key.public_key
    end
  end
end

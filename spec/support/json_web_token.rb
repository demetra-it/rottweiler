# frozen_string_literal: true

class JwtHelper
  class << self
    def encode(payload, ttl = 900)
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

    def private_key
      @private_key ||= File.read(File.join(File.dirname(__dir__), 'config', 'jwt_private_key.pem'))
    end

    def public_key
      @public_key ||= File.read(File.join(File.dirname(__dir__), 'config', 'jwt_public_key.pem'))
    end
  end
end

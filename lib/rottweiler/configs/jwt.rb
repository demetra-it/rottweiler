# frozen_string_literal true

module Rottweiler
  module Configs
    # Implements JWT configuration for Rottweiler
    class JWT
      ACCEPTED_ALGORITHMS = %w[RS256 RS384 RS512 HS256 HS384 HS512].freeze

      attr_reader :algorithm
      attr_accessor :decode_key

      def initialize
        @algorithm = 'RS256'
        @decode_key = nil
      end

      def algorithm=(algorithm)
        raise ArgumentError, 'JWT Algorithm must be a string' unless algorithm.is_a?(String)

        unless ACCEPTED_ALGORITHMS.include?(algorithm.upcase)
          raise ArgumentError, "Invalid JWT algorithm: #{algorithm}. Valid values are: #{ACCEPTED_ALGORITHMS}"
        end

        @algorithm = algorithm
      end
    end
  end
end

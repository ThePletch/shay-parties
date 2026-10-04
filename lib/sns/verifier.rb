# frozen_string_literal: true

require "aws-sdk-sns"

module Sns
  class Verifier
    class << self
      def authentic?(body)
        verifier.authentic?(body)
      rescue StandardError
        false
      end

      private

      def verifier
        @verifier ||= Aws::SNS::MessageVerifier.new
      end
    end
  end
end

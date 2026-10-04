# frozen_string_literal: true

require "aws-sdk-sns"

module Sns
  module BoundedCertFetch
    def https_get(uri, failed_attempts = 0)
      response = Sns::Https.get(uri)
      return response.body if response.code == "200"

      raise Aws::SNS::MessageVerifier::VerificationError, "signing cert request returned #{response.code}"
    rescue Aws::SNS::MessageVerifier::VerificationError
      raise
    rescue StandardError => error
      failed_attempts += 1
      retry if failed_attempts < 2

      raise Sns::Https::FetchError, error.message
    end
  end

  class Verifier
    class << self
      def authentic?(body)
        verifier.authenticate!(body)
      rescue Sns::Https::FetchError
        raise
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

unless Aws::SNS::MessageVerifier < Sns::BoundedCertFetch
  Aws::SNS::MessageVerifier.prepend(Sns::BoundedCertFetch)
end

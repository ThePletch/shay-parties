require "net/http"
require "json"

module Cloudflare
  class Turnstile
    VERIFY_URL = URI("https://challenges.cloudflare.com/turnstile/v0/siteverify")

    class << self
      def site_key
        ENV["TURNSTILE_SITE_KEY"]
      end

      def secret_key
        ENV["TURNSTILE_SECRET_KEY"]
      end

      def enabled?
        site_key.present? && secret_key.present?
      end

      # When keys are unset, skip verification outside production/staging so
      # local/dev/test can run without Cloudflare credentials.
      def verify(token, remote_ip: nil)
        return bypass_without_keys? unless enabled?
        return false if token.blank?

        response = Net::HTTP.post_form(
          VERIFY_URL,
          {
            "secret" => secret_key,
            "response" => token,
            "remoteip" => remote_ip,
          }.compact
        )
        return false unless response.is_a?(Net::HTTPSuccess)

        JSON.parse(response.body).fetch("success", false)
      rescue StandardError => e
        Rails.logger.error("Turnstile verification failed: #{e.class}: #{e.message}")
        false
      end

      private

      def bypass_without_keys?
        !(Rails.env.production? || Rails.env.staging?)
      end
    end
  end
end

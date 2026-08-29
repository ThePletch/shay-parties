# frozen_string_literal: true

module Webhooks
  class SesController < ApplicationController
    skip_forgery_protection
    skip_before_action :store_user_location!

    def create
      body = request.raw_post
      
      unless authentic?(body)
        head :forbidden
        return
      end

      payload = JSON.parse(body)
      case payload["Type"]
      when "SubscriptionConfirmation", "UnsubscribeConfirmation"
        confirm_subscription(payload["SubscribeURL"])
      when "Notification"
        Ses::NotificationProcessor.process(payload["Message"])
      end

      head :ok
    rescue JSON::ParserError
      head :bad_request
    end

    private

    def confirm_subscription(url)
      return if url.blank?
      return unless url.start_with?("https://sns.", "https://sns-")

      uri = URI.parse(url)
      return unless uri.host&.end_with?(".amazonaws.com")

      Net::HTTP.get(uri)
    end

    def authentic?(body)
      sns_verifier.authentic?(body)
    rescue StandardError
      false
    end

    def sns_verifier
      @sns_verifier ||= Aws::SNS::MessageVerifier.new
    end
  end
end

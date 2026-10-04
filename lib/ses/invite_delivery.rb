# frozen_string_literal: true

require "aws-sdk-sesv2"

module Ses
  class InviteDelivery
    class << self
      def deliver!(mailer_delivery, tags: {})
        mail = mailer_delivery.message
        if configuration_set.present?
          send_via_api(mail, tags)
        else
          mailer_delivery.deliver_now
          mail.message_id
        end
      end

      def configuration_set
        ENV["SES_CONFIGURATION_SET"].presence
      end

      private

      def send_via_api(mail, tags)
        response = client.send_email(
          from_email_address: Array(mail.from).first,
          destination: { to_addresses: Array(mail.to) },
          content: { raw: { data: mail.to_s } },
          configuration_set_name: configuration_set,
          email_tags: tags.map { |name, value| { name: name.to_s, value: value.to_s } }
        )
        response.message_id
      end

      def client
        Aws::SESV2::Client.new(region: ENV.fetch("SES_REGION", "us-east-1"))
      end
    end
  end
end

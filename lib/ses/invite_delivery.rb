# frozen_string_literal: true

require "aws-sdk-sesv2"
require "json"
require "resolv"
require "socket"

module Ses
  class InviteDelivery
    class << self
      def deliver!(mailer_delivery, tags: {})
        mail = mailer_delivery.message
        api = configuration_set.present?
        # #region agent log
        debug_log("A", "lib/ses/invite_delivery.rb:deliver!", "delivery branch", {
          api: api,
          configuration_set_present: api,
          smtp_address: Rails.application.config.action_mailer.smtp_settings&.dig(:address),
          region: ENV.fetch("SES_REGION", "us-east-1")
        })
        # #endregion
        if api
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
        started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        ses = client
        host = ses.config.endpoint.host
        families = address_families(host)
        dualstack_host = "email.#{ENV.fetch("SES_REGION", "us-east-1")}.api.aws"
        # #region agent log
        debug_log("B", "lib/ses/invite_delivery.rb:send_via_api", "ses endpoint address families", {
          endpoint: ses.config.endpoint.to_s,
          host: host,
          a_count: families[:a],
          aaaa_count: families[:aaaa],
          dualstack_host: dualstack_host,
          dualstack_aaaa_count: address_families(dualstack_host)[:aaaa],
          open_timeout: ses.config.http_open_timeout,
          read_timeout: ses.config.http_read_timeout,
          ipv6_connect: ipv6_connect(host),
          dualstack_ipv6_connect: ipv6_connect(dualstack_host)
        })
        # #endregion
        started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        response = ses.send_email(
          from_email_address: Array(mail.from).first,
          destination: { to_addresses: Array(mail.to) },
          content: { raw: { data: mail.to_s } },
          configuration_set_name: configuration_set,
          email_tags: tags.map { |name, value| { name: name.to_s, value: value.to_s } }
        )
        # #region agent log
        debug_log("C", "lib/ses/invite_delivery.rb:send_via_api", "ses send finished", {
          elapsed_ms: ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round,
          message_id_present: response.message_id.present?
        })
        # #endregion
        response.message_id
      rescue StandardError => e
        # #region agent log
        debug_log("C", "lib/ses/invite_delivery.rb:send_via_api", "ses send failed", {
          elapsed_ms: ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round,
          error_class: e.class.name,
          error_message: e.message.to_s[0, 200]
        })
        # #endregion
        raise
      end

      def client
        Aws::SESV2::Client.new(
          region: ENV.fetch("SES_REGION", "us-east-1"),
          use_dualstack_endpoint: true
        )
      end

      def address_families(host)
        resolver = Resolv::DNS.new
        {
          a: resolver.getresources(host, Resolv::DNS::Resource::IN::A).size,
          aaaa: resolver.getresources(host, Resolv::DNS::Resource::IN::AAAA).size
        }
      rescue StandardError
        { a: nil, aaaa: nil }
      end

      def ipv6_connect(host)
        addresses = Resolv::DNS.new.getresources(host, Resolv::DNS::Resource::IN::AAAA)
        return { result: "no_aaaa" } if addresses.empty?

        started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        Socket.tcp(addresses.first.address.to_s, 443, connect_timeout: 3) { |_socket| }
        { result: "ok", elapsed_ms: ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round }
      rescue StandardError => e
        { result: "error", error: e.class.name, message: e.message.to_s[0, 120] }
      end

      def debug_log(hypothesis_id, location, message, data)
        payload = {
          sessionId: "766739",
          hypothesisId: hypothesis_id,
          location: location,
          message: message,
          data: data,
          timestamp: (Time.now.to_f * 1000).to_i,
          runId: "pre-fix"
        }
        File.open("/Users/shay/Code/shay-parties/.cursor/debug-766739.log", "a") { |file| file.puts(payload.to_json) }
      rescue StandardError
        nil
      end
    end
  end
end

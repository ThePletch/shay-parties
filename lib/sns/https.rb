# frozen_string_literal: true

require "net/http"
require "socket"

module Sns
  module Https
    class FetchError < StandardError; end

    OPEN_TIMEOUT = 5
    READ_TIMEOUT = 5
    AMAZONAWS_HOST = /\Asns\.([a-z0-9-]+)\.amazonaws\.com\z/

    def self.get(uri)
      target = ipv6_endpoint(uri)
      options = {
        use_ssl: target.scheme == "https",
        verify_mode: OpenSSL::SSL::VERIFY_PEER,
        open_timeout: OPEN_TIMEOUT,
        read_timeout: READ_TIMEOUT,
      }
      ipv6 = ipv6_address(target.host)
      options[:ipaddr] = ipv6 if ipv6

      Net::HTTP.start(target.host, target.port, **options) do |http|
        http.request(Net::HTTP::Get.new(target.request_uri))
      end
    end

    def self.ipv6_endpoint(uri)
      region = AMAZONAWS_HOST.match(uri.host.to_s)&.[](1)
      return uri unless region

      rewritten = uri.dup
      rewritten.host = "sns.#{region}.api.aws"
      rewritten
    end

    def self.ipv6_address(host)
      Addrinfo.getaddrinfo(host, nil, Socket::AF_INET6, Socket::SOCK_STREAM).first&.ip_address
    rescue SocketError
      nil
    end
    private_class_method :ipv6_endpoint, :ipv6_address
  end
end

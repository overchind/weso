# frozen_string_literal: true

module Weso
  module Base
    # ::nodoc::
    class SocketCreator
      attr_reader :uri, :options

      DEFAULT_SSL_VERSION = 'SSLv23'

      def initialize(url, options)
        @uri = URI.parse(url)
        @options = options
      end

      def call
        socket = TCPSocket.new(uri.host, port)
        socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
        socket = process_secure(socket) if secure?
        socket
      end

      def secure?
        %w[https wss].include? uri.scheme
      end

      private

      def port
        uri.port || (uri.scheme == 'wss' ? 443 : 80)
      end

      def process_secure(socket)
        ssl_context = options[:ssl_context] || context

        socket = ::OpenSSL::SSL::SSLSocket.new(socket, ssl_context)
        socket.hostname = uri.host
        socket.connect
        socket
      end

      def context
        context = OpenSSL::SSL::SSLContext.new
        context.ssl_version = options[:ssl_version] || DEFAULT_SSL_VERSION
        context.verify_mode = options[:verify_mode] || OpenSSL::SSL::VERIFY_PEER
        context.cert_store  = options[:cert_store] || default_cert_store
        context
      end

      def default_cert_store
        cert_store = OpenSSL::X509::Store.new
        cert_store.set_default_paths
        cert_store
      end
    end
  end
end

# frozen_string_literal: true

require_relative './socket_creator'

module Weso
  module Base
    # ::nodoc::
    class Client
      include EventEmitter

      def connect(url, options = {})
        return if @socket

        @socket = socket_creator(url, options).call
        @closed = false

        @handshake = handshake_client(url, options[:headers])
        @handshaked = false

        handshake
        call_runner
        self
      end

      def send_data(data, type: :text)
        return unless open?

        @socket.write_nonblock output_frame(data, type)
        data
      end

      def handshake
        @socket.write(@handshake.to_s)
        process_socket(@socket, method(:handshaked?)) do |socket|
          @handshake = read_socket(socket, @handshake)
          @handshaked = @handshake.finished?
        end
      end

      def close(error = nil)
        return if closed?

        emit :close, error
      ensure
        close_socket
        close_runner
      end

      def open?
        !closed? && handshaked?
      end

      def closed?
        @closed
      end

      def handshaked?
        @handshaked
      end

      private

      def call_runner
        @runner = Thread.new(@socket) do |socket|
          emit :open
          frame = input_frame

          process_socket(socket, method(:closed?)) do |s|
            frame = read_socket(s, frame)
            frame = process_frame(frame)
          end
        end
      end

      def process_frame(frame)
        if (msg = frame.next)
          emit :message, msg
          return input_frame
        end

        frame
      end

      def process_socket(socket, condition_method) # rubocop:disable Metrics/MethodLength
        until condition_method.call
          read_sockets, = IO.select([socket], nil, nil, 10) # TODO: Configured timeout?

          next unless read_sockets && read_sockets[0]

          begin
            yield(socket)
          rescue IO::WaitReadable
            # Do nothing
          rescue IO::WaitWritable
            IO.select(nil, [socket])
            retry
          rescue EOFError => e
            emit :error, e
            close(e)
          rescue StandardError => e
            emit :error, e
          end
        end
      end

      def read_socket(socket, frame)
        frame << socket.read_nonblock(1024)
        frame << socket.read(socket.pending) while socket.respond_to?(:pending) && socket.pending.positive?
        frame
      end

      def input_frame
        ::WebSocket::Frame::Incoming::Client.new
      end

      def output_frame(data, type)
        ::WebSocket::Frame::Outgoing::Client.new(data: data, type: type, version: @handshake.version).to_s
      end

      def socket_creator(url, options)
        ::Weso::Base::SocketCreator.new(url, options)
      end

      def handshake_client(url, headers)
        ::WebSocket::Handshake::Client.new(url: url, headers: headers)
      end

      def close_socket
        @closed = true
        @socket&.close
        @socket = nil
      end

      def close_runner
        Thread.kill @runner if @runner
      end
    end
  end
end

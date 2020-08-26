# frozen_string_literal: true

module Faulty
  module Events
    class LogListener
      attr_reader :logger

      def initialize(logger = nil)
        logger ||= defined?(Rails) ? Rails.logger : Logger.new($stderr)
        @logger = logger
      end

      def handle(event, payload)
        return unless EVENTS.include?(event)

        public_send(event, payload) if respond_to?(event)
      end

      def circuit_cache_hit(payload)
        log(:debug, 'Circuit cache hit', payload[:circuit].name, key: payload[:key])
      end

      def circuit_cache_miss(payload)
        log(:debug, 'Circuit cache miss', payload[:circuit].name, key: payload[:key])
      end

      def circuit_cache_write(payload)
        log(:debug, 'Circuit cache write', payload[:circuit].name, key: payload[:key])
      end

      def circuit_success(payload)
        log(:debug, 'Circuit succeeded', payload[:circuit].name, state: payload[:status].state)
      end

      def circuit_failure(payload)
        log(
          :error, 'Circuit failed', payload[:circuit].name,
          state: payload[:status].state,
          error: payload[:error].message
        )
      end

      def circuit_skipped(payload)
        log(:warn, 'Circuit skipped', payload[:circuit].name)
      end

      def circuit_opened(payload)
        log(:error, 'Circuit opened', payload[:circuit].name, error: payload[:error].message)
      end

      def circuit_reopened(payload)
        log(:error, 'Circuit reopened', payload[:circuit].name, error: payload[:error].message)
      end

      def circuit_closed(payload)
        log(:info, 'Circuit closed', payload[:circuit].name)
      end

      def cache_failure(payload)
        log(
          :error, 'Cache failure', payload[:action],
          key: payload[:key],
          error: payload[:error].message
        )
      end

      def storage_failure(payload)
        log(
          :error, 'Storage failure', payload[:action],
          circuit: payload[:circuit].name,
          error: payload[:error].message
        )
      end

      private

      def log(level, msg, action, extra = {})
        extra_str = extra.map { |k, v| "#{k}=#{v}" }.join(' ')
        logger.public_send(level, "#{msg}: #{action} #{extra_str}")
      end
    end
  end
end

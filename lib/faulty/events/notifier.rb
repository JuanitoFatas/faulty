# frozen_string_literal: true

module Faulty
  module Events
    class Notifier
      def initialize(listeners = [])
        @listeners = listeners.freeze
      end

      def notify(event, payload)
        raise "Unknown event #{event}" unless EVENTS.include?(event)

        @listeners.each { |l| l.handle(event, payload) }
      end
    end
  end
end
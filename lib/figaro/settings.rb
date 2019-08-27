# frozen_string_literal: true

require 'bigdecimal'

module Figaro
  #
  # This class should be extended in your own application to provide a higher
  # level API for use in your application.
  #
  # Your app shouldn't use ENV, Figaro.env not Settings#[]. It also shouldn't
  # fiddle with data conversion in settings.
  #
  # class Settings < Figaro::Settings
  #   requires :per_page # makes it fail on startup
  #   requires :port,
  #     :int
  #
  #   def per_page
  #     self[:per_page].int
  #   end
  # end
  #
  class Settings
    attr_reader :namespace

    NAMESPACE_SEPARATOR = '__'.freeze

    module ClassMethods
      def [](key)
        new(key)
      end

      def requires(key, type = nil)
        setting = self[key]
        if type
          setting.as type,
            raises: true
        else
          setting.value || raise(MissingKey, key)
        end
      end
    end
    extend ClassMethods

    def initialize(namespace)
      @namespace = [namespace]
    end

    def [](key)
      self.class.new(namespace + [key])
    end

    def key
      ns = namespace || []
      ns.join NAMESPACE_SEPARATOR
    end

    def value
      env.send key
    end

    def to_str
      value
    end

    def to_s
      value
    end

    def inspect
      "Setting: #{key} => #{value.inspect}"
    end

    module DataTypes
      FALSY_VALUES = %w[no off false disabled].freeze

      NULLABLE_TYPES = {
        int: method(:Integer),
        float: method(:Float),
        decimal: method(:BigDecimal),
        string: ->(itself) { itself || raise(ArgumentError) }
      }.freeze

      class InvalidKey < Error
        def initialize(setting, type)
          super("Invalid configuration key: can't convert #{setting.inspect} to #{type}")
        end
      end

      def as(type, raises: false)
        case type
        when :bool
          bool
        else
          conversion = NULLABLE_TYPES[type]
          conversion.call value
        end
      rescue ArgumentError, TypeError
        raise InvalidKey.new(self, type) if raises
      end

      def bool
        !FALSY_VALUES.include? value&.downcase
      end

      NULLABLE_TYPES.each do |method, _conversion|
        define_method method do
          as method
        end

        define_method "#{method}!" do
          as method,
            raises: true
        end
      end
    end
    include DataTypes

    private
    def env
      Figaro.env
    end
  end
end

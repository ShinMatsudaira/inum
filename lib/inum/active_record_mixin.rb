module Inum
  # Mixin module to ActiveRecord.
  #
  # @example
  #   class Fruit < ActiveRecord::Base
  #     bind_enum :type, FruitType
  #   end
  #
  module ActiveRecordMixin
    # Define compare method in class.
    #
    # @param column     [Symbol]      Binding column name.
    # @param enum_class [Inum::Base]  Binding Enum.
    # @param options    [Hash]        option
    # @option options [Symbol]    :prefix     Prefix. (default: column)
    # @option options [Symbol]    :strict     Raise if value was not found in enum_class. (default: column)
    # @option options [Symbol]    :string     Raise if value was not found in enum_class. (default: column)
    def bind_inum column, enum_class, **options
      options[:prefix] = options[:prefix] ? "#{column}_" : "#{options[:prefix]}_"
      parse_method     = options[:strict] ? 'parse!' : 'parse'
      valuate_method   = options[:string] ? 'value' : 'to_i'

      self.class_eval do
        define_method(column) do
          enum_class.send(parse_method, read_attribute(column))
        end

        define_method("#{column}=") do |value|
          enum_class.send(parse_method, value).tap do |enum|
            if enum
              write_attribute(column, enum.send(valuate_method))
            else
              write_attribute(column, nil)
            end
          end
        end

        enum_class.each do |enum|
          define_method("#{options[:prefix]}#{enum.to_s.underscore}?") do
            enum.eql?(read_attribute(column))
          end
        end
      end
    end
  end
end

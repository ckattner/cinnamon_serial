# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module CinnamonSerial
  # This is the main parent class that all serializers must inherit from.
  class Base
    extend Dsl

    class << self
      def map(enumerable, opts = {})
        enumerable.map { |e| new(e, opts) }
      end
    end

    attr_reader :data,
                :obj,
                :opts,
                :klasses

    def initialize(obj, opts = {}, klasses = Set.new)
      @obj     = obj
      @opts    = opts || {}
      @klasses = klasses

      materialize_data
      execute_hydrate_blocks
    end

    def dig_opt(*keys)
      opts.dig(*keys)
    end

    def as_json(_options = {})
      data
    end

    def respond_to_missing?(method_sym)
      data.key?(method_sym.to_s) || super
    end

    def method_missing(method_sym, *arguments, &block)
      key = method_sym.to_s.sub('set_', '')

      if data.key?(method_sym.to_s)
        data[method_sym.to_s]
      elsif data.key?(key)
        @data[key] = arguments[0]
      else
        super
      end
    end

    def [](attr)
      send(attr)
    end

    private

    def inherited_cinnamon_serial_specification
      self.class.inherited_cinnamon_serial_specification
    end

    def materialize_data
      @data = {}

      # Soft dependency on ActiveSupport.
      # If it is understood how to create indifferently accessible hashes, then let's prefer that.
      @data = @data.with_indifferent_access if @data.respond_to?(:with_indifferent_access)

      inherited_cinnamon_serial_specification.attribute_map.each do |key, options|
        @data[key.to_s] = options.resolve(self, key)
      end

      nil
    end

    def execute_hydrate_blocks
      inherited_cinnamon_serial_specification.hydrate_blocks.each do |block|
        if block && block.arity == 1
          block.call(self)
        elsif block
          instance_eval(&block)
        end
      end

      nil
    end
  end
end

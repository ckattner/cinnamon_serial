# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module CinnamonSerial
  # A Specification is a group of attribute mappings and custom code blocks to execute
  # for a serializer.
  class Specification
    attr_reader :attribute_map, :hydrate_blocks

    def initialize(attribute_map: {}, hydrate_blocks: [])
      @attribute_map  = attribute_map
      @hydrate_blocks = hydrate_blocks
    end

    def set(*keys)
      keys = keys.flatten

      # We have been sent options
      options = Resolver.new(keys.last.is_a?(Hash) ? keys.pop : {})

      raise ArgumentError, 'keys cannot be empty' if keys.empty?

      keys.each { |key| @attribute_map[key.to_s] = options }

      nil
    end

    def hydrate(block)
      @hydrate_blocks << block

      nil
    end
  end
end

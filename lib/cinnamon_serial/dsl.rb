# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module CinnamonSerial
  # This module includes all the class-level methods used to specify serializers.
  module Dsl
    def cinnamon_serial_specification
      @cinnamon_serial_specification ||= Specification.new
    end

    def serialize(*keys)
      cinnamon_serial_specification.set(keys)

      nil
    end

    def hydrate(&block)
      cinnamon_serial_specification.hydrate(block)

      nil
    end

    def inherited_cinnamon_serial_specification
      return @inherited_cinnamon_serial_specification if @inherited_cinnamon_serial_specification

      attribute_map  = {}
      hydrate_blocks = []

      # We need to reverse this so parents go first.
      ancestors.reverse_each do |ancestor|
        next unless ancestor.respond_to?(:cinnamon_serial_specification)

        specification = ancestor.cinnamon_serial_specification

        attribute_map.merge!(specification.attribute_map)
        hydrate_blocks += specification.hydrate_blocks
      end

      @inherited_cinnamon_serial_specification = Specification.new(
        attribute_map: attribute_map,
        hydrate_blocks: hydrate_blocks
      )
    end
  end
end

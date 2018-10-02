# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module CinnamonSerial
  # Static utility methods for general use.
  class Formatting
    class << self
      # Only show the last N positions in a string, replace the
      # rest with the mask_with value.
      # Example:
      # - 123-45-6789 becomes: XXXXXXX6789
      # - ABCDEFG     becomes: XXXDEFG
      def mask(value, keep_last = 4, mask_with = 'X')
        string_value = value.to_s
        return string_value if string_value.blank? || string_value.size <= keep_last

        (mask_with.to_s * (string_value.size - keep_last)) + string_value[-keep_last..-1]
      end

      def percent(num)
        num.present? ? format('%.2f %', num) : ''
      end
    end
  end
end

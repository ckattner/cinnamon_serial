# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module CinnamonSerial
  # Class that allows an engineer to specify what to do about mapping a key for a serializer.
  class Resolver
    attr_accessor :as,
                  :blank,
                  :false_alias,
                  :for,
                  :manual,
                  :mask,
                  :mask_char,
                  :mask_len,
                  :method,
                  :null,
                  :percent,
                  :present,
                  :through,
                  :transform,
                  :true_alias

    def initialize(options = {})
      @option_keys = options.keys.map(&:to_s).to_set

      options.each do |key, value|
        raise ArgumentError, "Illegal option: #{key}" unless respond_to?(key)

        send("#{key}=", value)
      end
    end

    def resolve(presenter, key)
      raise ArgumentError, 'Presenter is required' unless presenter

      return if manual

      # Get the value
      value = resolve_value(presenter, key)

      # Transform the value
      value = resolve_transform(presenter, key, value)
      value = resolve_alias(value)
      value = resolve_as(presenter, value)

      # Format the value
      value = resolve_percent(value)
      resolve_mask(value)
    end

    private

    # (method) and (for/through) are mutually exlusive use-cases.
    # Example: you would never use for and method.
    def resolve_value(presenter, key)
      # If you pass in something that is not true boolean value then use that as a method name
      # to call on the presenter.
      return presenter.send(key)    if method.is_a?(TrueClass)
      return presenter.send(method) if method.to_s.length.positive?

      # User for/through
      model_key = self.for || key
      model = presenter.obj

      Array(through).each do |association|
        model = model.respond_to?(association) ? model.send(association) : nil

        break unless model
      end

      model&.respond_to?(model_key) ? model.send(model_key) : nil
    end

    def resolve_transform(presenter, key, value)
      return presenter.send(key, value)       if transform.is_a?(TrueClass)
      return presenter.send(transform, value) if Formatting.present?(transform)

      value
    end

    def resolve_alias(value)
      if @option_keys.include?('true_alias') && value.is_a?(TrueClass)
        true_alias
      elsif @option_keys.include?('false_alias') && value.is_a?(FalseClass)
        false_alias
      elsif @option_keys.include?('null') && value.nil?
        null
      elsif @option_keys.include?('blank') && Formatting.blank?(value)
        blank
      elsif @option_keys.include?('present') && Formatting.present?(value)
        present
      else
        value
      end
    end

    def resolve_mask(value)
      mask ? Formatting.mask(value, mask_len || 4, mask_char || 'X') : value
    end

    def resolve_percent(value)
      percent ? Formatting.percent(value) : value
    end

    def resolve_as(presenter, value)
      return value  unless as
      return nil    unless value

      class_constant = as_class_constant

      # If we already serialized this type, lets not do it again.
      # This will prevent endless cycles / loops.
      return nil if presenter.klasses.include?(class_constant.to_s)

      # We do not want to create a hard dependency on ActiveRecord/Rails in this gem,
      # but we can still create a soft dependency in case it was included as a peer.
      value = value.to_a if value.class.name == 'ActiveRecord::Relation'

      new_klasses = presenter.klasses + Set[class_constant.to_s]

      if value.is_a?(Array)
        value.map { |v| class_constant.new(v, presenter.opts, new_klasses) }
      else
        class_constant.new(value, presenter.opts, new_klasses)
      end
    end

    def as_class_name
      return nil unless as

      non_constant_types = %w[String Symbol]

      # If we have a peer dependency for ActiveSupport then lets use it.
      if non_constant_types.include?(as.class.name) && as.to_s.respond_to?(:classify)
        as.to_s.classify
      elsif non_constant_types.include?(as.class.name)
        as.to_s
      else
        as
      end
    end

    def as_class_constant
      return nil unless as

      class_name = as_class_name

      # If we have a peer dependency for ActiveSupport then lets use it.
      if class_name.is_a?(String) && class_name.respond_to?(:constantize)
        class_name.constantize
      elsif class_name.is_a?(String)
        Object.const_get(class_name)
      else
        class_name
      end
    end
  end
end

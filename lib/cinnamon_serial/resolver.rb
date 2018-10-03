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
                  :false,
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
                  :true

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
      return presenter.send(transform, value) if transform.to_s.length.positive?

      value
    end

    def resolve_alias(value)
      if @option_keys.include?('true') && value.is_a?(TrueClass)
        self.true
      elsif @option_keys.include?('false') && value.is_a?(FalseClass)
        self.false
      elsif @option_keys.include?('null') && value.nil?
        null
      elsif @option_keys.include?('blank') && value.blank?
        blank
      elsif @option_keys.include?('present') && value.present?
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

      klass = as.to_s.classify.constantize

      # cycle buster 2000
      return nil if @klasses.include?(klass.to_s)

      value = value.to_a if value.class.name == 'ActiveRecord::Relation'

      new_klasses = @klasses + Set[klass.to_s]

      if value.is_a?(Array)
        value.map { |v| klass.new(v, presenter.opts, new_klasses) }
      else
        klass.new(value, presenter.opts, new_klasses)
      end
    end
  end
end

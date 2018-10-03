# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

Employee = Struct.new(:id, :name, :start_date, :job, :manager)

# ######################################################
# A Class that exemplifies all possible mapping options.
# ######################################################
class EmployeeListSerializer < CinnamonSerial::Base
  # Test skipping mapping using 'manual'
  serialize :active, manual: true

  # ################
  # Value Resolution
  # ################

  # Test basic 1:1 mapping
  serialize :id, :name

  # Test presenter 'method'
  serialize :user_id,   method: true
  serialize :user_name, method: :formatted_user_name

  # Test 'for'
  serialize :other_id, for: :id

  # Test 'for' and 'through'
  serialize :manager_name, for: :name, through: :manager

  # ################
  # Value Aliasing
  # ################

  # Test presenter 'transform' method
  serialize :renewal_date,  for: :start_date, transform: true
  serialize :notify_date,   for: :start_date, transform: :notification_date

  # Test 'true' alias

  #serialize :true_value, true: 'I am true.'

  # Test 'false' alias

  # Test 'null' alias

  # Test 'present' alias

  # Test 'blank' alias

  # Test 'as' conversion

  # ################
  # Value Formatting
  # ################

  # #######################
  # Manual Hydration Blocks
  # #######################
  hydrate do
    set_active(dig_opt(:active))
  end

  # ##############
  # Custom Methods
  # ##############

  private

  def user_id
    dig_opt(:user, :id)
  end

  def formatted_user_name
    dig_opt(:user, :name)
  end

  def renewal_date(date)
    # Two years out
    date + (60 * 60 * 24 * 24)
  end

  def notification_date(date)
    # 23 months out
    date + (60 * 60 * 24 * 23)
  end
end

# #############################
# Subclass to test inheritance.
# #############################
class EmployeeSerializer < EmployeeListSerializer
  present :start_date, :job

  present :founder,
          :owner, manual: true

  hydrate do
    set_founder(obj.id < 10)
  end

  hydrate do
    set_owner(obj.id == 1)
  end
end

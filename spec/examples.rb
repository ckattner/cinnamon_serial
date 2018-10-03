# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

class Employee
  attr_accessor :id,
                :name,
                :start_date,
                :job,
                :account,
                :progress,
                :manager,
                :employees

  def initialize(
    id:,
    name:,
    start_date:,
    job:,
    account:,
    progress:,
    manager: nil,
    employees: []
  )
    @id         = id
    @name       = name
    @start_date = start_date
    @job        = job
    @account    = account
    @progress   = progress
    @manager    = manager
    @employees  = employees
  end

  def true_alias_value
    true
  end
  alias true_value true_alias_value

  def false_alias_value
    false
  end
  alias false_value false_alias_value

  def null
    nil
  end

  def blank
    ''
  end

  def present
    'abc123.'
  end

end

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

  # <b>DEPRECATED:</b> Please use <tt>true_alias</tt> instead.
  serialize :true_value,        true: 'I am true.'
  serialize :true_alias_value,  true_alias: 'I am true alias.'

  # Test 'false' alias

  # <b>DEPRECATED:</b> Please use <tt>false_alias</tt> instead.
  serialize :false_value,       false: 'I am false.'
  serialize :false_alias_value, false_alias: 'I am false alias.'

  # Test 'null' alias
  serialize :null,              null: 'I am null.'

  # Test 'present' alias
  serialize :present,           present: 'I am present.'

  # Test 'blank' alias
  serialize :blank,             blank: 'I am blank.'

  # Test 'as' conversion
  serialize :manager,           as: 'EmployeeSerializer'
  serialize :employees,         as: 'EmployeeSerializer'

  # ################
  # Value Formatting
  # ################

  serialize :account,           mask: true
  serialize :progress,          percent: true

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

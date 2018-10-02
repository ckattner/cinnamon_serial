# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

Employee = Struct.new(:id, :name, :dob, :job)

class EmployeeListSerializer < CinnamonSerial::Base
  serialize :id, :name

  serialize :active, manual: true

  hydrate do
    set_active(dig_opt(:active))
  end
end

class EmployeeSerializer < EmployeeListSerializer
  present :dob, :job

  present :founder,
          :owner, manual: true

  hydrate do
    set_founder(obj.id < 10)
  end

  hydrate do
    set_owner(obj.id == 1)
  end
end

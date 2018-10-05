# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'date'
require 'pry'
require './lib/cinnamon_serial'
require './spec/examples'

describe CinnamonSerial::Dsl do
  let(:employee_list_keys) do
    %w[
      active
      id
      name
      user_id
      user_name
      other_id
      manager_name
      renewal_date
      notify_date
      true_alias_value
      false_alias_value
      null
      present
      blank
      manager
      employees
      account
      progress
    ]
  end

  let(:employee_keys) do
    employee_list_keys + %w[
      start_date
      job
      founder
      owner
    ]
  end

  it 'should include all attribute mappings' do
    specification = EmployeeListSerializer.cinnamon_serial_specification
    attribute_map = specification.attribute_map
    keys = attribute_map.keys

    expect(specification).to  be_a_kind_of(CinnamonSerial::Specification)
    expect(keys.count).to     eq(employee_list_keys.count)
    expect(keys).to           eq(employee_list_keys)
  end

  context 'with inheritance' do
    it 'should include only its immediate attribute mappings' do
      specification = EmployeeSerializer.cinnamon_serial_specification
      attribute_map = specification.attribute_map
      keys = attribute_map.keys

      expect(specification).to  be_a_kind_of(CinnamonSerial::Specification)
      expect(keys.count).to     eq(4)
      expect(keys).to           eq(%w[start_date job founder owner])
    end

    it 'should include its immediate and ancestor attribute mappings' do
      specification = EmployeeSerializer.inherited_cinnamon_serial_specification
      attribute_map = specification.attribute_map
      keys = attribute_map.keys

      expect(specification).to  be_a_kind_of(CinnamonSerial::Specification)
      expect(keys.count).to     eq(employee_keys.count)
      expect(keys).to           eq(employee_keys)
    end
  end
end

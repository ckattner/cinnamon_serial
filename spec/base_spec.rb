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

describe CinnamonSerial::Base do
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

  context 'while using the dsl' do
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

  context 'while constructing presenters' do
    let(:nick) { Employee.new(2, 'nick', Date.new(1350, 12, 12), 'electrician') }
    let(:matt) { Employee.new(1, 'matt', Date.new(1750, 12, 12), 'plumber', nick) }

    it 'should materialize_data and execute hydrate blocks' do
      opts                = { user: { id: 100, name: 'Frank Rizzo' }, active: true }
      employee_serializer = EmployeeSerializer.new(matt, opts)
      data                = employee_serializer.data

      expect(data['id']).to           eq(matt.id)
      expect(data['name']).to         eq(matt.name)
      expect(data['user_id']).to      eq(opts[:user][:id])
      expect(data['user_name']).to    eq(opts[:user][:name])
      expect(data['other_id']).to     eq(matt.id)
      expect(data['manager_name']).to eq(nick.name)
      expect(data['renewal_date']).to eq(matt.start_date + (60 * 60 * 24 * 24))
      expect(data['notify_date']).to  eq(matt.start_date + (60 * 60 * 24 * 23))
      expect(data['active']).to       eq(opts[:active])
      expect(data['start_date']).to   eq(matt.start_date)
      expect(data['job']).to          eq(matt.job)
      expect(data['founder']).to      eq(matt.id < 10)
      expect(data['owner']).to        eq(matt.id == 1)
    end
  end
end

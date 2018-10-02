# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'pry'
require './lib/cinnamon_serial'
require './spec/examples'

describe CinnamonSerial::Base do
  context 'while using the dsl' do
    it 'should include all attribute mappings' do
      specification = EmployeeListSerializer.cinnamon_serial_specification
      attribute_map = specification.attribute_map
      keys = attribute_map.keys

      expect(specification).to  be_a_kind_of(CinnamonSerial::Specification)
      expect(keys.count).to     eq(3)
      expect(keys).to           eq(%w[id name active])
    end

    context 'with inheritance' do
      it 'should include only its immediate attribute mappings' do
        specification = EmployeeSerializer.cinnamon_serial_specification
        attribute_map = specification.attribute_map
        keys = attribute_map.keys

        expect(specification).to  be_a_kind_of(CinnamonSerial::Specification)
        expect(keys.count).to     eq(4)
        expect(keys).to           eq(%w[dob job founder owner])
      end

      it 'should include its immediate and ancestor attribute mappings' do
        specification = EmployeeSerializer.inherited_cinnamon_serial_specification
        attribute_map = specification.attribute_map
        keys = attribute_map.keys

        expect(specification).to  be_a_kind_of(CinnamonSerial::Specification)
        expect(keys.count).to     eq(7)
        expect(keys).to           eq(%w[id name active dob job founder owner])
      end
    end
  end

  context 'while constructing presenters' do
    let(:matt) { Employee.new(1, 'matt', '1750-12-12', 'plumber') }

    it 'should materialize_data and execute hydrate blocks' do
      opts                = { active: true }
      employee_serializer = EmployeeSerializer.new(matt, opts)
      data                = employee_serializer.data

      expect(data['id']).to       eq(matt.id)
      expect(data['name']).to     eq(matt.name)
      expect(data['active']).to   eq(opts[:active])
      expect(data['dob']).to      eq(matt.dob)
      expect(data['job']).to      eq(matt.job)
      expect(data['founder']).to  eq(matt.id < 10)
      expect(data['owner']).to    eq(matt.id == 1)
    end
  end
end

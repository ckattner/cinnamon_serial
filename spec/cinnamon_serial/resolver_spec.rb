# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require './spec/spec_helper'
require './spec/examples'

describe CinnamonSerial::Resolver do
  let(:presented_employee) do
    CinnamonSerial::Base.new(
      OpenStruct.new(
        name: 'employee',
        manager: OpenStruct.new(id: 2, name: 'manager')
      )
    )
  end

  let(:presented_manager_employees_array) do
    CinnamonSerial::Base.new(
      OpenStruct.new(
        name: 'manager',
        employees: [
          OpenStruct.new(id: 1, name: 'employee 1'),
          OpenStruct.new(id: 2, name: 'employee 2')
        ]
      )
    )
  end

  let(:presented_manager_employees_active_record_relation) do
    # Stub this out so this gem does not have to depends directly on ActiveRecord:
    module ActiveRecord
      class Relation
      end
    end

    module CinnamonSerial
      class ResolverSpecFakeRelation < ActiveRecord::Relation
        def initialize(data)
          @data = data
        end

        def to_a
          @data
        end
      end
    end

    CinnamonSerial::Base.new(
      OpenStruct.new(
        name: 'manager',
        employees: CinnamonSerial::ResolverSpecFakeRelation.new(
          [
            OpenStruct.new(id: 1, name: 'employee 1'),
            OpenStruct.new(id: 2, name: 'employee 2')
          ]
        )
      )
    )
  end

  describe '"as" resolving' do
    let(:subject) { described_class.new(as: SimpleEmployeeSerializer) }

    it 'single instance resolves to an instance of the specified class' do
      value = subject.resolve(presented_employee, 'manager')

      expect(value).to be_a SimpleEmployeeSerializer
      expect(value.data).to eq('id' => 2, 'name' => 'manager')
    end

    it 'wraps each element of an array in the presenter as specified' do
      value = subject.resolve(presented_manager_employees_array, :employees)

      expect(value).to be_a Array
      expect(value.map(&:class).uniq).to eq [SimpleEmployeeSerializer]

      expect(value[0].data).to eq('id' => 1, 'name' => 'employee 1')
      expect(value[1].data).to eq('id' => 2, 'name' => 'employee 2')
    end

    it 'wraps each element of an ActiveRecord::Relation in the presenter as specified' do
      value = subject.resolve(presented_manager_employees_active_record_relation, :employees)

      expect(value).to be_a Array
      expect(value.map(&:class).uniq).to eq [SimpleEmployeeSerializer]

      expect(value[0].data).to eq('id' => 1, 'name' => 'employee 1')
      expect(value[1].data).to eq('id' => 2, 'name' => 'employee 2')
    end
  end
end

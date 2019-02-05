# frozen_string_literal: true

#
# Copyright (c) 2018-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require './spec/spec_helper'
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

  let(:nick) do
    Employee.new(
      id: 2,
      name: 'nick',
      start_date: Date.new(1350, 12, 12),
      job: 'electrician',
      account: '1234567890',
      progress: 55.5,
      employees: [
        Employee.new(
          id: 1,
          name: 'matt',
          start_date:
          Date.new(1750, 12, 12),
          job: 'plumber',
          account: '98765443322111',
          progress: 10.98
        )
      ]
    )
  end

  let(:matt) do
    Employee.new(
      id: 1,
      name: 'matt',
      start_date:
      Date.new(1750, 12, 12),
      job: 'plumber',
      account: '98765443322111',
      progress: 10.98,
      manager: nick
    )
  end

  let(:opts)                { { user: { id: 100, name: 'Frank Rizzo' }, active: true } }
  let(:employee_serializer) { EmployeeSerializer.new(matt, opts) }
  let(:data)                { employee_serializer.data }

  it 'should materialize_data and execute hydrate blocks for superclass' do
    expect(data['id']).to           eq(matt.id)
    expect(data['name']).to         eq(matt.name)
    expect(data['user_id']).to      eq(opts[:user][:id])
    expect(data['user_name']).to    eq(opts[:user][:name])
    expect(data['other_id']).to     eq(matt.id)
    expect(data['manager_name']).to eq(nick.name)
    expect(data['renewal_date']).to eq(matt.start_date + (60 * 60 * 24 * 24))
    expect(data['notify_date']).to  eq(matt.start_date + (60 * 60 * 24 * 23))

    expect(data['true_alias_value']).to   eq('I am true alias.')
    expect(data['false_alias_value']).to  eq('I am false alias.')
    expect(data['null']).to               eq('I am null.')
    expect(data['present']).to            eq('I am present.')
    expect(data['blank']).to              eq('I am blank.')
    expect(data['manager']).to            be_a_kind_of(EmployeeSerializer)

    expect(data['account']).to            eq('XXXXXXXXXX2111')
    expect(data['progress']).to           eq('10.98 %')
  end

  it 'should materialize_data and execute hydrate blocks for subclass' do
    expect(data['active']).to       eq(opts[:active])
    expect(data['start_date']).to   eq(matt.start_date)
    expect(data['job']).to          eq(matt.job)
    expect(data['founder']).to      eq(matt.id < 10)
    expect(data['owner']).to        eq(matt.id == 1)
  end

  it 'should not create cycles when flattening out presenters' do
    expect(data['manager'].employees).to be nil
  end

  it 'should treat hashes like objects' do
    employee = {
      id: 1,
      name: 'Mittens the cat'
    }

    serializer = SimpleEmployeeSerializer.new(employee)

    expect(serializer.data['id']).to    eq(employee[:id])
    expect(serializer.data['name']).to  eq(employee[:name])
  end
end

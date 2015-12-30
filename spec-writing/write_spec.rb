require 'ostruct'
require 'rspec'
require_relative '../lib/sis_ruby/client'

# TODO Add tests for invalid items

TEST_SERVER_URL = 'http://localhost:3000'

def describe_test(test_name, source_data)

  # Note that although real world servers should use https,
  # this server only works with http when installed and configured
  # with the instructions at https://github.com/sis-cmdb/sis-api

  client = SisRuby::Client.new(TEST_SERVER_URL)
  data = OpenStruct.new(source_data)
  id_field = data.id_field
  endpoint = data.entity_type ? client.entities(data.entity_type) : client.send(data.type)

  describe test_name do

    before(:all) do
      client.authenticate('test', 'abc123')
      if data.required_schema
        client.schemas.create(data.required_schema)
      end
    end

    if data.required_schema
      after(:all) do
        client.schemas.delete(data.required_schema)
      end
    end

    valid_items = data.valid_items || []
    valid_items.each_with_index do |item, index|

      it "should create, get, list, and delete valid item #{index}" do

        # Test creation ................................................
        result = endpoint.create(item)
        expect(result).to be, 'Result returned by create was nil.'
        id = result[id_field]
        name = result['name']

        expect(id).to be, 'Id on create was nil, or record not created.'

        # Test retrieval with get.......................................
        result = endpoint.get(id)

        if data.type == 'hiera' # special type of data, extract inner data structure for test
          expected = { id => item['hieradata'] }
          expect(result).to eq(expected)
        else
          actual_id = result[id_field]
          expect(actual_id).to eq(id), "Get error; expected id '#{id}' but got '#{actual_id}'"
        end

        # Test retrieval with list.......................................
        expect(endpoint.list.any?).to eq(true), 'List returned no records.'

        # Test deletion - result will be the deleted record..............
        result = endpoint.delete(id)
        actual_name = result['name']
        actual_id = result[id_field]
        expect(actual_id).to eq(id), "After delete, expected id '#{id}' but got '#{actual_id}'"
        expect(actual_name).to eq(name), "After delete, expected name '#{name}' but got '#{actual_name}'"

        # Ensure that the get fails since we just deleted the record
        expect { endpoint.get(id) }.to raise_error(SisRuby::BadResponseError)
      end
    end
  end
end


# Generates test expectations for the specified data type.
# Assumes that:
#
# 1) the file containing the specified type of data contains JSON text
# 2) the file is in the same directory as this test file
# 3) the file is named: type + '.json'
def process_test_data(type)
  filespec = File.join(File.dirname(__FILE__), type + '.json')
  data = JSON.parse(File.read(filespec))
  describe_test(type, data)
end


describe 'Authentication Error Handling' do
  it 'should raise a Client::AuthenticationError with bad credentials' do
    client = SisRuby::Client.new(TEST_SERVER_URL)
    expect { client.authenticate('test', 'bad-password') }.to \
        raise_error(SisRuby::Client::AuthenticationError, /HTTP\/1.1 401/)
  end
end


def main
  %w(entity hiera hook schema).each { |type| process_test_data(type) }
end


main


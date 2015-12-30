require_relative 'spec_helper'
require_relative '../lib/sis_ruby/exceptions/missing_id_error'

module SisRuby

describe Endpoint do

  let(:id_fieldname)   { '_id_' }
  let(:server_url)     { 'https://fictitious-domain.com' }
  let(:client)         { Client.new(server_url) }
  let(:host_endpoint)  { client.entities('host', id_fieldname) }

  context '#id_from_param' do

    it 'works with an object other than hash' do
      expect(host_endpoint.id_from_param(3)).to eq(3)
    end

    it 'works with a hash' do
      expect(host_endpoint.id_from_param({ id_fieldname => 3 } )).to eq(3)
    end

    it 'raises an error on nil' do
      expect { host_endpoint.id_from_param(nil) }.to raise_error(MissingIdError)
      expect { host_endpoint.id_from_param( { id_fieldname => nil } ) }.to raise_error((MissingIdError))
    end
  end


  context '#==' do

    specify '2 endpoints created with the same parameters are ==' do
      create_endpoint = -> { Endpoint.new(client, 'abcxyz', 'foo') }
      endpoint_0 = create_endpoint.()
      endpoint_1 = create_endpoint.()
      expect(endpoint_1).to eq(endpoint_0)
    end

    specify '2 endpoints created with different clients are not ==' do
      client1 = Client.new('url1')
      client2 = Client.new('url2')
      expect(Endpoint.new(client1, 'foo')).not_to eq(Endpoint.new(client2, 'foo'))
    end

    specify '2 endpoints created with different endpoint names are not ==' do
      expect(Endpoint.new(client, 'foo')).not_to eq(Endpoint.new(client, 'bar'))
    end

    specify '2 endpoints created with different id fields are not ==' do
      expect(Endpoint.new(client, 'foo', 'x')).not_to eq(Endpoint.new(client, 'foo', 'y'))
    end
  end
end
end

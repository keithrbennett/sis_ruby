require_relative 'spec_helper'
require_relative '../lib/sis_ruby/exceptions/missing_id_error'

# These tests test client behavior that does not require a server.

module SisRuby

  describe Client do

    let(:server_url)     { 'https://fictitious-domain.com' }
    let(:id_fieldname)   { '_id_' }
    let(:client)         { Client.new(server_url) }
    let(:host_endpoint)  { client.entities('host', id_fieldname) }

    context 'constructor parameters' do

      specify 'omitting version gets default version' do
        expect(client.api_version).to eq(Client::DEFAULT_API_VERSION)
      end

      specify 'overriding default version works' do
        api_v = 'v_not_default'
        expect(Client.new(server_url, api_version: api_v).api_version).to eq(api_v)
      end

      specify 'setting auth_token works' do
        auth_token = 'abcdefgxyz'
        expect(Client.new(server_url, auth_token: auth_token).auth_token).to eq(auth_token)
      end

    end

    context 'precreated endpoints' do

      specify 'are precreated' do
        endpoints = [client.hooks, client.schemas, client.hiera]
        expect(endpoints.all? { |ep| ep.is_a?(Endpoint) }).to eq(true)
      end

      specify 'have URLs that end in the right name' do
        endpoints = [client.hooks, client.schemas, client.hiera]
        endpoints_and_names = endpoints.zip(%w(hooks  schemas  hiera))
        expect(endpoints_and_names.all? { |ep, name| ep.url.end_with?(name) }).to eq(true)
      end
    end


    context 'tokens' do

      specify 'the URL is correct' do
        username = 'david_bisbal'
        token = client.tokens(username)
        expect(token.url.end_with?("users/#{username}/tokens")).to eq(true)
      end
    end
  end
end

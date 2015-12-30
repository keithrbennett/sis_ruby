require_relative 'common'
require 'sis_ruby/endpoint'
require 'typhoeus'

module SisRuby

class Client

  attr_reader :api_version, :auth_token, :base_url, :entity_endpoints, :hiera, :hooks, :hosts, :schemas

  DEFAULT_API_VERSION = '1.1'

  # @param url the base URL of the service (excluding ''/api/v...'')
  # @param options (can include :version, :auth_token)
  def initialize(url, options = {})
    @base_url = url
    @api_version = options[:api_version] || DEFAULT_API_VERSION
    @auth_token = options[:auth_token]

    @entity_endpoints = {}
    @hooks   = create_endpoint('hooks',   'name')
    @schemas = create_endpoint('schemas', 'name')
    @hiera   = create_endpoint('hiera',   'name')
  end


  def create_endpoint(endpoint_suffix, id_fieldname = :default)
    Endpoint.new(self, endpoint_suffix, id_fieldname)
  end


  def entities(name, id_fieldname = DEFAULT_ID_FIELDNAME)
    @entity_endpoints[name] ||= create_endpoint("entities/#{name}", id_fieldname)
  end


  def tokens(username)
    create_endpoint("users/#{username}/tokens", 'name')
  end


  # Returns the schema for the specified collection_name, or nil if it's not found.
  def schema_for(collection_name)
    params = Params.new.limit(1).filter('name' => collection_name)
    schemas.list(params).first
  end


  # Authenticates the username and password. Get the token by calling client.auth_token.
  # @return self for chaining this method after the constructor
  def authenticate(username, password)
    dest = "#{base_url}/api/v#{api_version}/users/auth_token"
    options = {
        userpwd: username + ':' + password,
        headers: { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
    }
    response = Typhoeus.post(dest, options)
    unless response.options[:response_code] == 201
      raise AuthenticationError.new(response)
    end

    @auth_token = JSON.parse(response.response_body)['name']
    self
  end


  def to_s
    self.class.name + ": base_url = #{@base_url}"
  end



  class AuthenticationError < Exception

    def initialize(response)
      @response = response
    end

    def to_s
      @response.options[:response_headers].split("\r\n").first
    end
  end

end
end

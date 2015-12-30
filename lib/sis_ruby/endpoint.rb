require 'typhoeus'
require 'json'

require_relative 'client'
require_relative 'common'
require_relative 'get_helper'
require_relative 'result_enumerable'
require_relative 'exceptions/missing_id_error'

module SisRuby

class Endpoint

  include GetHelper

  attr_reader :client, :id_field, :url


  def initialize(client, endpoint_name, id_field = DEFAULT_ID_FIELDNAME)
    @client = client
    @url = "#{client.base_url}/api/v#{client.api_version}/#{endpoint_name}"
    @id_field = id_field
  end


  # This method is used to allow callers to pass either the id itself,
  # or the record including an id key/value pair.
  def id_from_param(object)
    id = object.is_a?(Hash) ? object[@id_field] : object
    id ? id : raise(MissingIdError.new("Missing required id field #{@id_field}}"))
  end


  def create_enumerable(params = {}, chunk_size = ResultEnumerable::DEFAULT_CHUNK_RECORD_COUNT)
    ResultEnumerable.new(self, params, chunk_size)
  end


  # Gets the total count of records, with optional filter
  def count(filter = {})
    params = Params.new.filter(filter).limit(1).to_hash
    response = Typhoeus::Request.new(@url, params: params, headers: create_headers(true)).run
    response.headers['x-total-count'].to_i
  end


  # Anything implementing a to_hash method can be passed as the query.
  # This enables the passing in of SisParams objects.
  def list(params = {})
    create_enumerable(params).each.to_a
  end


  # Anything implementing a to_hash method can be passed as the query.
  # This enables the passing in of SisParams objects.
  def list_as_openstructs(query = {})
    list(query).map { |h| OpenStruct.new(h) }
  end


  def get(id)
    request = Typhoeus::Request.new("#{url}/#{id}", headers: create_headers(true))
    response = request.run
    validate_response_success(response)
    JSON.parse(response.body)
  end


  def create(obj)
    http_response = Typhoeus.post(@url, { body: obj.to_json, headers: get_headers(true) } )
    validate_response_success(http_response)
    JSON.parse(http_response.body)
  end


  def delete(id)
    id = id_from_param(id)
    http_response = Typhoeus.delete("#{@url}/#{id}", headers: get_headers(false))
    validate_response_success(http_response)
    JSON.parse(http_response.body)
  end


  def update(obj)
    id = id_from_param(obj)
    http_response = self.class.put("#{@url}/#{id}", {body: obj.to_json, headers: get_headers(true) })
    validate_response_success(http_response)
    JSON.parse(http_response.body)
  end


  def to_s
    self.class.name + ": endpoint = #{@url}, client = #{@client}"
  end


  def ==(other)
    client.equal?(other.client) && url == other.url && id_field == other.id_field
  end

  private

  def get_headers(specify_content_type)
    create_headers(specify_content_type, @client.auth_token)
  end
end

end

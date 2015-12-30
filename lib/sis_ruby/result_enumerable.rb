require 'trick_bag'
require 'ostruct'
require 'typhoeus'
require_relative 'get_helper'
require_relative 'params'


module SisRuby


# This class is an enumerator over a result set of SIS objects, as specified
# in a hash-like object (that is, any object that implements to_hash,
# such as a SisParams instance).  It can be used as any Enumerable;
# that is, methods such as each, map, select, etc. can be called;
# an array of all results can be produced by calling to_a,
# and an Enumerator can be gotten by calling each without a chunk.
#
# Internally it fetches chunks of records only when needed to serve the values
# to the caller.  The chunk size can be specified by the caller.
#
# By calling each or each_slice you can access some of the data before fetching
# all of it. This can be handy if:
#
# 1) there may not be enough available memory to process the entire result set
#    at once
# 2) you want to process some records while others are being fetched, by
#    using multiple threads, for example.
#
class ResultEnumerable < TrickBag::Enumerables::BufferedEnumerable

  include GetHelper
  include Enumerable

  DEFAULT_CHUNK_RECORD_COUNT = 5_000


  # @param endpoint_url the SIS endpoint URL string or an Endpoint instance
  # @param params any object that implements to_hash, e.g. a Params instance
  # @param chunk_size the maximum number of records to fetch from the server in a request
  def initialize(endpoint_url, params = {}, chunk_size = DEFAULT_CHUNK_RECORD_COUNT)
    super(chunk_size)
    @endpoint_url = endpoint_url.is_a?(Endpoint) ? endpoint_url.url : endpoint_url
    @outer_params = params.is_a?(Params) ? params : Params.from_hash(params.to_hash)

    inner_limit = @outer_params.limit ? [chunk_size, @outer_params.limit].min : chunk_size
    @inner_params = @outer_params.clone.limit(inner_limit)

    @inner_params.offset ||= 0
    @position     = 0
    @total_count  = nil
  end


  def fetch
    # This exits the fetching when the desired number of records has been fetched.
    if @outer_params.limit && @yield_count >= @outer_params.limit
      self.data = []
      return
    end

    request = Typhoeus::Request.new(@endpoint_url, params: @inner_params.to_hash, headers: create_headers(true))
    response = request.run
    validate_response_success(response)
    self.data = JSON.parse(response.body)
    @total_count = response.headers['x-total-count'].to_i
    @inner_params.offset(@inner_params.offset + chunk_size)

    # TODO: Deal with this
    # if @total_count > chunk_size && @inner_params.sort.nil?
    #   raise "Total count (#{@total_count}) exceeds chunk size (#{chunk_size})." +
    #       "When this is the case, a sort order must be specified, or chunk size increased."
    # end
  end


  def total_count
    fetch unless @total_count
    @total_count
  end


  def fetch_notify
    # puts "Fetch at #{Time.now}: chunk size: #{chunk_size}, yield count: #{yield_count}, total count = #{@total_count}"
  end
end
end
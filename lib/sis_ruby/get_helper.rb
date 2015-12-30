require_relative 'exceptions/bad_response_error'


# Methods for helping get data from SIS.
module SisRuby
  module GetHelper

    # Creates the header for a request.
    def create_headers(specify_content_type, auth_token = nil)
      headers = {
          'Accept' => 'application/json'
      }

      if auth_token
        headers['x-auth-token'] = auth_token
      end

      if specify_content_type
        headers['Content-Type'] = 'application/json'
      end

      headers
    end


    # Raises an error on response failure.
    def validate_response_success(response)
      unless response.code.between?(200, 299)
        raise BadResponseError.new(response)
      end
    end


    # Returns a Typhoeus response.
    def typhoeus_get(query)
      # TODO: Simplify w/Typhoeus.get ?
      Typhoeus::Request.new(url,  params: query, headers: get_headers(true) ).run
    end

  end
end
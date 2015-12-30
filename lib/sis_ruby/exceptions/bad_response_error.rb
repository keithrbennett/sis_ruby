module SisRuby

class BadResponseError < RuntimeError

  attr_reader :response

  def initialize(response)
    @response = response
  end


  def to_s

    first_header_line = if response && response.options[:response_headers]
      header_lines = response.options[:response_headers].split("\r\n")
      header_lines.any? ? header_lines.first : nil
    else
      nil
    end

    body = if response && response.options[:response_body]
     response.options[:response_body].rstrip
    else
      nil
    end

    code = response.code

    string = "#{self.class.name}: #{code}"
    string << ": #{body}" if body
    string << (first_header_line ? " (#{first_header_line})" : '')
    string
  end
end
end

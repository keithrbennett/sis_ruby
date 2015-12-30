#!/usr/bin/env ruby

require 'sis_ruby'
require 'awesome_print'

include SisRuby

raise "Must specify SIS server URL in SIS_URL environment variable." unless ENV['SIS_URL']
client = Client.new(ENV['SIS_URL'])
host_endpoint = client.entities('host')

records = host_endpoint.list(Params.new.fields('hostname').limit(3))
puts "Fetched #{records.size} host records."
puts "Last one is: #{records.last}, host name is #{records.last['hostname']}"


full_record = host_endpoint.list(Params.new.limit(1)).first
puts 'Host record keys:'
ap full_record.keys

puts "\n\n"
query = Params.new.limit(1).fields('hostname', 'fqdn', 'status')
result = host_endpoint.list_as_openstructs(query).first
puts "Host: #{result.hostname}, FQDN: #{result.fqdn}, Status: #{result.status}"
puts "\nEntire record:"
ap result

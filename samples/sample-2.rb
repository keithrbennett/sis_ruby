#!/usr/bin/env ruby

require 'awesome_print'
require 'pry'
require 'sis_ruby'

raise "Must specify SIS server URL in SIS_URL environment variable." unless ENV['SIS_URL']
client = Client.new(ENV['SIS_URL'])
HOSTS = client.entities('host')
# puts "Total host count is #{hosts.count}"
# puts "Total qa host count is  #{hosts.count('environment' => 'qa')}"

# p1 = SisRuby::Params.new.sort('host').offset(9000).limit(2)
# p1 = SisRuby::Params.new.sort('host').offset(9000).limit(2).fields('hostname', 'environment')
# records = hosts.list(p1)
# ap records.first


def fetch(count, offset)
  HOSTS.list(SisRuby::Params.new.fields('hostname').limit(count).offset(offset))
end

arrays = (0..10).to_a.map { |i| fetch(1000, i * 1000) }
a_combined = arrays.flatten
a_uniq = a_combined.uniq
host_names = a_combined.map { |h| h['hostname'] }

puts "Combined count is #{a_combined.size}"
puts "Unique count is #{a_uniq.size}"
puts "Host name count is #{host_names.size}"
puts "Unique host name count is #{host_names.uniq.size}"
binding.pry


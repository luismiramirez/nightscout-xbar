#!/usr/bin/env ruby

# <xbar.title>Nightscout display</xnar.title>
# <xbar.version>v2.1.7</xbar.version>
# <xbar.desc>Display your glucose levels from the Nightscout site</xbar.desc>
# <xbar.dependencies>ruby</xbar.dependencies>
# <xbar.author>Luismi Ramirez</xbar.author>
# <xbar.author.github>luismiramirez</xbar.author.github>

require 'json'
require 'net/https'
require 'uri'

# Edit these values with yours
SITE = 'https://your-nightscout-site.example/'
TOKEN = 'your-token'
UNIT = 'mg/dl'
LIMITS = {
  'mg/dl' => {
    very_high: 260,
    high: 180,
    low: 70,
    very_low: 55
  },
  'mmol/L' => {
    very_high: 14.4,
    high: 10,
    low: 3.9,
    very_low: 3.1
  }
}

NIGHTSCOUT_URI = URI(
  "#{SITE}/api/v3/entries/history?token=#{TOKEN}&limit=2"
).freeze
TEN_MINUTES_AGO = Time.now.utc - 600

def request_data
  req = Net::HTTP::Get.new(NIGHTSCOUT_URI.request_uri)
  req['Last-Modified'] = TEN_MINUTES_AGO
  http_client.request(req)
rescue
  puts 'Error connecting to Nightscout'
  exit 0
end

def http_client
  http = Net::HTTP.new(NIGHTSCOUT_URI.host, NIGHTSCOUT_URI.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER

  http
end

def parse_values(parsed_response)
  {
    previous: parsed_response.first['sgv'],
    current: parsed_response.last['sgv'],
    direction: direction_map.fetch(parsed_response.last['direction'], '')
  }
end

def calculate_delta(previous, current)
  delta = current - previous
  return delta if delta.zero?

  operator = delta.positive? ? '+' : '-'
  "#{operator} #{delta.abs}"
end

def direction_map
  {
    'FortyFiveUp' => '↗',
    'FortyFiveDown' => '↘',
    'SingleUp' => '↑',
    'SingleDown' => '↓',
    'Flat' => '→',
    'DoubleUp' => '⇈',
    'DoubleDown' => '⇊',
    'NotComputable' => '-'
  }
end

def determine_icon(current_value)
  limits_by_unit = LIMITS[UNIT]

  if current_value >= limits_by_unit[:very_high] || current_value <= limits_by_unit[:very_low]
    '🚨'
  elsif current_value >= limits_by_unit[:high] || current_value <= limits_by_unit[:low]
    '⚠️'
  else
    '👍'
  end
end

response = request_data
values = parse_values(JSON[response.body]['result'])
delta = calculate_delta(values[:previous], values[:current])
icon = determine_icon(values[:current])

puts [icon, values[:current], values[:direction], delta, UNIT].join(' ')
puts '---'
puts "Your Nightscout site | href=#{SITE}"

require 'faraday'
require 'json'
require 'time'
require '/actions/github_api_client'
require '/actions/slack_client'

keys = %w(GITHUB_BASE_URL REPOSITORY GITHUB_TOKEN SLACK_WEBHOOK LIMIT_DAYS NOTIFY_TEMPLATE CLOSED_TEMPLATE)
puts '---- envs ----------------------'
keys.each do |key|
  if ENV[key].empty?
    raise "key: #{key} is not specified.abort."
  end
  puts "[key: #{key}]"
  pp ENV[key]
end
puts '--------------------------------'

GITHUB_BASE_URL = "#{ENV['GITHUB_BASE_URL']}/#{ENV['REPOSITORY']}"
TOKEN = ENV['GITHUB_TOKEN']
SLACK_WEBHOOK_URL = ENV['SLACK_WEBHOOK']
IGNORE_LABELS = ENV['IGNORE_LABELS'].split(',')
LIMIT = (Time.now - ENV['LIMIT_DAYS'].to_i * 24 * 60 * 60).iso8601
HEADERS = {
  'Authorization' => "Bearer #{TOKEN}",
  'Accept' => 'application/vnd.github.v3+json'
}
NOTIFY_TEMPLATE = ENV['NOTIFY_TEMPLATE']
CLOSED_TEMPLATE = ENV['CLOSED_TEMPLATE']

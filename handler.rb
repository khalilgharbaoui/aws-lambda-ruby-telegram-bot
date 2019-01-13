require 'json'
require_relative 'http_requester'

BASE_URL =
  "https://api.telegram.org/#{ENV['TELEGRAM_TOKEN']}".freeze

def hello(event:, context:)
  data =
    event['body'].is_a?(Hash) ? event['body']['message'] : parsed(event['body'])

  message = data['text'].to_s
  first_name = data.dig('chat', 'first_name')
  response = "Please /start, #{first_name}"

  if message == '/start'
    response = "Hello #{first_name}, you started!"
    data = {
      "text":     response.force_encoding('utf-8'),
      "chat_id":  data.dig('chat', 'id')
    }
    url = BASE_URL + '/sendMessage'
    HttpRequester.post(data.to_json, url)
  end
  { "statusCode": 200, "body": data.to_json }
rescue Exception => e
  puts e.message
  puts e.backtrace.inspect
end

def parsed(event_body)
  JSON.parse(event_body, quirks_mode: true)['message']
end

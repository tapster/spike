# Set up dummy api
Spike::Config.connection = Faraday.new(url: 'http://sushi.com') do |faraday|
  faraday.request   :json
  faraday.response  :json
  faraday.adapter   Faraday.default_adapter
end

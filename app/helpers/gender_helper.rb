require "open-uri"

module GenderHelper
  def genders_data(base_url)
    json_url = "#{base_url}/genders.json"
    JSON.parse URI.open(json_url).read
  end
end

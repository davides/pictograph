require 'rest_client'
require 'json'

class InstagramClient
  def initialize(access_token)
    @access_token = access_token
  end

  def follows(user_id)
    list_resources_at(follows_url_for(user_id))
  end

  def followers(user_id)
    list_resources_at(followers_url_for(user_id))
  end

private
  def list_resources_at url
    result = []

    loop do
      puts "GET #{url}"
      response = RestClient.get(url)
      data = JSON.parse(response.to_str)
      data["data"].each {|u| result << u }
      break if !data["pagination"] || !data["pagination"]["next_url"]
      url = data["pagination"]["next_url"]
    end

    result
  end

  def follows_url_for(user_id)
    base_url + "/users/#{user_id}/follows?access_token=#{@access_token}"
  end

  def followers_url_for(user_id)
    base_url + "/users/#{user_id}/followed-by?access_token=#{@access_token}"
  end

  def base_url
    "https://api.instagram.com/v1"
  end
end
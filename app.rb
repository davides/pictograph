require 'sinatra'
require 'rest_client'
require 'json'

require './env'

$redirect_uri = 'http://localhost:4567/callback'

get '/' do
  client_id = ENV['INSTAGRAM_CLIENT_ID']
  auth_url = "https://api.instagram.com/oauth/authorize/?client_id=#{client_id}&redirect_uri=#{$redirect_uri}&response_type=code"

  erb :index, :locals => {
    auth_url: auth_url
  }
end

get '/dashboard' do
  erb :dashboard
end

get '/callback' do
  code = params[:code]
  client_id = ENV['INSTAGRAM_CLIENT_ID']
  client_secret = ENV['INSTAGRAM_CLIENT_SECRET']

  url = "https://api.instagram.com/oauth/access_token" #+ 
    # "?client_id=#{client_id}" + 
    # "&client_secret=#{client_secret}" + 
    # "&grant_type=authorization_code" +
    # "&redirect_uri=#{$redirect_uri}" +
    # "&code=#{code}"

  response = RestClient.post url, {
    "client_id" => client_id,
    "client_secret" => client_secret,
    "grant_type" => "authorization_code",
    "redirect_uri" => $redirect_uri,
    "code" => code
  }

  puts response.to_str

  data = JSON.parse(response.to_str)

  erb :auth, :locals => {
    :access_token => data["access_token"],
    :username => data["user"]["username"],
    :profile_picture => data["user"]["profile_picture"]
  }
end
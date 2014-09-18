require 'sinatra'
require 'rest_client'
require 'json'

require './env'
require './array_utils'
require './instagram_client'

# Constants
# 
$redirect_uri = 'http://localhost:4567/callback'


# Middleware
# 
use Rack::Session::Pool, :expire_after => 2592000
set :session_secret, ENV['RACK_SESSION_SECRET']


##
# The main view for un-authenticated users.
# 
get '/' do
  if session[:access_token] and session[:user_id]
    return redirect to("/dashboard")
  end

  # Build a URL to kick off the OAuth flow
  client_id = ENV['INSTAGRAM_CLIENT_ID']
  auth_url = "https://api.instagram.com/oauth/authorize/" + 
    "?client_id=#{client_id}" +
    "&redirect_uri=#{$redirect_uri}" +
    "&response_type=code"

  erb :index, :locals => {
    auth_url: auth_url
  }
end


##
# Gathers data and renders the main view.
# 
get '/dashboard' do
  if not session[:access_token] or not session[:user_id]
    return redirect to("/")
  end

  access_token = session[:access_token]
  user_id = session[:user_id]
  username = session[:username]
  profile_picture = session[:profile_picture]

  client = InstagramClient.new(access_token)

  follows = client.follows(user_id)
  followers = client.followers(user_id)
  unrequited = ArrayUtils.except(follows, followers) {|u| u["username"]}
  not_following = ArrayUtils.except(followers, follows) {|u| u["username"]}

  erb :dashboard, :locals => {
    profile_picture: profile_picture,
    username: username,
    follows: follows,
    followers: followers,
    unrequited: unrequited,
    not_following: not_following
  }
end

##
# Called by Instagram to complete the server-side OAuth flow.
# It will be called with a query parameter that can be exchanged
# for an access_token (e.g. https://host/callback?code=<code>)
# 
get '/callback' do
  code = params[:code]
  client_id = ENV['INSTAGRAM_CLIENT_ID']
  client_secret = ENV['INSTAGRAM_CLIENT_SECRET']

  # Exchange code for an access_token
  url = "https://api.instagram.com/oauth/access_token"
  response = RestClient.post url, {
    "client_id" => client_id,
    "client_secret" => client_secret,
    "grant_type" => "authorization_code",
    "redirect_uri" => $redirect_uri,
    "code" => code }
  data = JSON.parse(response.to_str)

  session[:access_token] = data["access_token"]
  session[:user_id] = data["user"]["id"]
  session[:username] = data["user"]["username"]
  session[:profile_picture] = data["user"]["profile_picture"]

  redirect to("/dashboard")
end
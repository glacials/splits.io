class TwitchController < ApplicationController
  def out
    redirect_to "#{auth_uri}?response_type=code&client_id=#{client_id}&redirect_uri=#{redirect_uri}&scope=user_read"
  end

  def in
    uri   = URI.parse('https://api.twitch.tv/kraken/oauth2/token')
    token = HTTParty.post(uri.to_s, query: post_params)['access_token']

    uri      = URI.parse("https://api.twitch.tv/kraken/user?oauth_token=#{token}")
    response = HTTParty.get(uri.to_s)

    user = User.find_by(twitch_id: response['_id']) || User.new
    user.twitch_token = token
    user.load_from_twitch(response)
    user.save

    sign_in(:user, user)
    user.remember_me!(100.years)

    flash = {notice: "Signed in as #{current_user.name} :D"}
    if cookies[:return_to]
      redirect_to cookies[:return_to], flash: flash
      cookies.delete(:return_to)
    else
      redirect_to root_path, flash: flash
    end
  end

  private

  def client_id
    ENV['TWITCH_CLIENT_ID']
  end

  def client_secret
    ENV['TWITCH_CLIENT_SECRET']
  end

  def redirect_uri
    "http://#{request.host_with_port}/signin/twitch/auth"
  end

  def auth_uri
    'https://api.twitch.tv/kraken/oauth2/authorize'
  end

  def post_params
    {
      client_id:     client_id,
      client_secret: client_secret,
      grant_type:    'authorization_code',
      redirect_uri:  redirect_uri,
      code:          params[:code]
    }
  end
end

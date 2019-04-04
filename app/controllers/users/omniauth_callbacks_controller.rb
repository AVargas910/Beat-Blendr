class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def spotify
    @user = User.from_omniauth(request.env['omniauth.auth'])
    @user.refresh_my_token if @user.token_is_expired?

    top_tracks_response = HTTParty.get("https://api.spotify.com/v1/me/top/tracks/?limit=25",
                   headers: headers)

    if top_tracks_response["items"].count === 0
      if @user.persisted?
        set_flash_message(:notice, :success, :kind => "Spotify") if is_navigational_format?
        sign_in_and_redirect @user, :event => :authentication and return      
      else
        session['devise.spotify_data'] = request.env['omniauth.auth']
        redirect_to new_user_registration_url
      end

    else

      track_ids = []
      track_detail_ids = ''
      top_tracks_response["items"].each do |item|
        track_ids << item["id"]
        track_detail_ids = track_ids.join(",")
      end

      features_response = HTTParty.get("https://api.spotify.com/v1/audio-features/?ids=#{track_detail_ids}",
                          headers: headers)

      artists_response = HTTParty.get("https://api.spotify.com/v1/tracks/?ids=#{track_detail_ids}",
                          headers: headers)

      UserTrack.where(user: @user).delete_all

      top_tracks_response["items"].each do |item|
        track = Track.find_or_create_by(
          name: item["name"],
          spotify_id: item["id"],
        )
      UserTrack.find_or_create_by(user: @user, track: track)
      end

      features_response["audio_features"].each do |audio_features|
        Track.where(spotify_id: audio_features["id"]).update_all(danceability: audio_features["danceability"], energy: audio_features["energy"], speechiness: audio_features["speechiness"], tempo: audio_features["tempo"])
      end

      artists_response["tracks"].each do |tracks|
        Track.where(spotify_id: tracks["id"]).update_all(artist: tracks["artists"].first["name"])
      end
    end

      if @user.persisted?
        sign_in_and_redirect @user, :event => :authentication
        set_flash_message(:notice, :success, :kind => "Spotify") if is_navigational_format?
      else
        session['devise.spotify_data'] = request.env['omniauth.auth']
        redirect_to new_user_registration_url
      end
    end

  def failure
    redirect_to root_path
  end

  private

  def headers
    { "Authorization" => "Bearer #{@user.token}" }
  end

end

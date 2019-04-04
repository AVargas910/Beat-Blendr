class PlaylistsController < ApplicationController
  skip_before_action :verify_authenticity_token
  require 'pry'

  def create
    playlist_response = HTTParty.post(
                          "https://api.spotify.com/v1/users/#{current_user.uid}/playlists",
                          headers: headers,
                          body: {
                            "name" => "BeatBlender Event Playlist"
                          }.to_json
                        )
    playlist_id = playlist_response['id']
    playlist = current_user.create_playlist(
      playlist_id: playlist_id,
      playlist_type: params[:playlistType],
      range: params[:range]
    )

    tracks = []
    if nearby_users.length === 1
      User.all.each do |user|
        tracks << user.tracks
                      .send(params[:playlistType])
                      .pluck(:spotify_id)
      end
    else
      nearby_users.each do |user|
            tracks << user.tracks
                          .send(params[:playlistType])
                          .pluck(:spotify_id)
          end
    end
    tracks.flatten!
    tracks.shuffle!
    tracks.map!{|spotify_id| "spotify:track:#{spotify_id}"}
    track_response  = HTTParty.post(
                        "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks",
                        headers: headers,
                        body: { "uris" => tracks }.to_json
                      )
    render json: playlist
  end

  def destroy
    playlist = current_user.playlist
    HTTParty.delete(
      "https://api.spotify.com/v1/playlists/#{playlist.playlist_id}/followers",
      headers: headers
    )
    playlist.destroy
    render json: playlist
  end

  private

  def headers
    {
      "Authorization" => "Bearer #{current_user.token}",
      "Content-Type" => "application/json"
    }
  end

  def nearby_users
    User.near([current_user.latitude, current_user.longitude], (current_user.playlist.range / 5280))
  end

end

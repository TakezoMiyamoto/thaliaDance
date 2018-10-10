class MyworksController < ApplicationController
  def index
      google
  end

  def google
    res = request.env['omniauth.auth']


    if res
      token = res.credentials.token

      url = "https://www.googleapis.com/youtube/v3/channels?part=snippet,contentDetails,statistics,topicDetails&mine=true&access_token=#{token}"
      response = JSON.parse(Net::HTTP.get(URI.parse(URI.escape(url))))

      if response.try(:[], :errors)
        render json: { errors: response.errors }, status: :bad_request
      else
        key = "AIzaSyBk5cIAOqpkmHGz7v9iH5eAxVv1UVjjkCI"
        urll = "https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=#{response["items"].first["id"]}&key=#{key}"
        videos = JSON.parse(Net::HTTP.get(URI.parse(URI.escape(urll))))

        body = {
          token: token,
          response: response,
          videos: videos
        }
        render json: body
      end
    else
      render json: { errors: "Sorry! Error omniauth" }, status: :bad_request
    end
  end



private
def main
  require 'youtube.rb'
  client, youtube = get_authenticated_service

    begin
      # Retrieve the "contentDetails" part of the channel resource for the
      # authenticated user's channel.
      channels_response = client.execute!(
        :api_method => youtube.channels.list,
        :parameters => {
          :mine => true,
          :part => 'contentDetails',
          # access_token:
        }
      )

      channels_response.data.items.each do |channel|
        # From the API response, extract the playlist ID that identifies the list
        # of videos uploaded to the authenticated user's channel.
        uploads_list_id = channel['contentDetails']['relatedPlaylists']['uploads']

        # Retrieve the list of videos uploaded to the authenticated user's channel.
        next_page_token = ''
        until next_page_token.nil?
          playlistitems_response = client.execute!(
            :api_method => youtube.playlist_items.list,
            :parameters => {
              :playlistId => uploads_list_id,
              :part => 'snippet',
              :maxResults => 25,
              :pageToken => next_page_token
            }
          )

          @works = []

           # Print information about each video.
           playlistitems_response.data.items.each do |playlist_item|
             @works << playlist_item.snippet
             puts playlist_item.snippet.resourceId.videoId

           end

           next_page_token = playlistitems_response.next_page_token
         end

         puts
      end
    rescue Google::APIClient::TransmissionError => e
      puts e.result.body
    end
  end
end

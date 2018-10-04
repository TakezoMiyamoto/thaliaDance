class WorksController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]

    def index
      # get_data("formeraction")

    end

    

    def test
      return a=1
    end

    def my_works
        main
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
            :part => 'contentDetails'
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


# -------------------------------------------------------------------------
  def get_data(keyword)
    require 'youtube.rb'#先ほど上で準備したファイルを呼ぶ
    opts = Trollop::options do
      opt :q, 'Search term', :type => String, :default => keyword
      opt :max_results, 'Max results', :type => :int, :default => 25
      opt :order, 'order', :type => String, :default => 'date'
      opt :regionCode, 'region', :type => String, :default => 'JP'
    end

    client, youtube = get_service

    begin

      search_response = client.execute!(
        :api_method => youtube.search.list,
        :parameters => {
          :part => 'snippet',
          :q => opts[:q],
          :maxResults => opts[:max_results],
          :order => opts[:order],
          :regionCode => opts[:regionCode]
        }
      )

      @works = []
        search_response.data.items.each do |search_result|
         @works << search_result.id.video_id
        end

    rescue Google::APIClient::TransmissionError => e
      puts e.result.body
    end
  end
# -------------------------------------------------------------------------

  def works_params
    params.require(:work).permit(:title, :youtube_id, :thumbnail, :description, :youtube_url)
  end

  def edit_work_params
    params.require(:work).permit(:title, :youtube_id, :thumbnail, :description, :youtube_url)
  end

  def works_owner
    @work = Work.find(params[:id])
    unless @work.user_id == current_user.id
      flash[:notice] = 'Access denied as you are not owner of this work'
      redirect_to works_path
    end
  end

class WorksController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]

  def index
     @works = Work.order(created_at: :desc)
     @title = 'ワークス一覧'
    end

    def show
     @work = Work.find(params[:id])
    end

    def new
     @work = Work.new
     @title = '新規ワークの作成'
    end

    def create
     @work = current_user.works.build(works_params)
     if @work.save
       flash[:success] = "新規Workを作成しました！"
       redirect_to @work
     else
       render 'new'
     end
    end

    def edit
     @work = Work.find(params[:id])
    end

    def update
     @work = Work.find(params[:id])
     if @work.update(edit_work_params)
       flash[:success] = 'ワーク内容が更新されました。'
       redirect_to @work
     else
       render 'edit'
     end
    end

    def destroy
     @work = current_user.works.find_by(id: params[:id])
     return redirect_to root_url if @work.nil?
     @work.destroy
     flash[:success] = 'ワークは削除されました.'
     redirect_to works_path
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


# -------------------------------------------------------------------------
  def get_data(keyword)
    require 'youtube.rb'
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

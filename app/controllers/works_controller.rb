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

    def google
      res = request.env['omniauth.auth']
      @user = User.find_for_google_oauth2(request.env["omniauth.auth"])

      if @user
        token = @user.credentials.token

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
end

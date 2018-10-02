class WorksController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]

    def index
      get_data("formeraction")

    end

    def test
      return a=1
    end

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



  private

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

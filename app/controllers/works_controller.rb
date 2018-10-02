class WorksController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  
  def index
    @works = Work.order(created_at: :desc)
    @title = 'ワークス一覧'
  end

  def show
    @work = Work.find(params[:id])
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

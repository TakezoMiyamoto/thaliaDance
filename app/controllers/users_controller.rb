class UsersController < ApplicationController
  before_action :authenticate_user!, only:[:create, :edit, :update, :destroy]
  before_action :set_user, only:[:show, :edit, :update]
  def index
    @user = User.all
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

  def show
    @userName = @user.name
    @works = @user.works.group('works.id')

  end

  def edit
    @user = User.find(params[:id])

  end

  def update
    if @user.errors[:base].empty? and @user.update(edit_user_params)
      sign_in(@user, :bypass => true)
      flash[:success] = "プロフィールは更新されました"
      redirect_to @user
    else
      flash[:danger] = "プロフィールの更新に失敗しました"
      redirect_to user_path(current_user.id)
    end
  end

  



  private

  def edit_user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :avatar, :introduce)
  end

  def set_user
    @user = User.find(params[:id])
  end

end

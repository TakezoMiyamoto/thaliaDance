require "net/http"

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def google_oauth2
    callback_from :google_oauth2
  end

  private

  def callback_from(provider)
    provider = provider.to_s
    res = request.env["omniauth.auth"]

    if res
      @user = User.find_for_google_oauth2(res)

       if @user.persisted?
         token = res.credentials.token

         url = "https://www.googleapis.com/youtube/v3/channels?part=snippet,contentDetails,statistics,topicDetails&mine=true&access_token=#{token}"
         response = JSON.parse(Net::HTTP.get(URI.parse(URI.escape(url))))


         if response.try(:[], :errors)
           render json: { errors: response.errors }, status: :bad_request
         else
           key = ENV['GOOGLE_APP_CONTENT_KEY']
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
         session["devise.#{provider}_data"] = res
         redirect_to new_user_registration_url
       end
    else
      render json: { errors: "Sorry! Error omniauth" }, status: :bad_request
    end
  end
end

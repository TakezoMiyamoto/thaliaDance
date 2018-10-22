class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :works

   def self.find_for_google_oauth2(auth)
       user = User.where(email: auth.info.email).first
       unless user
         user = User.create(name:     auth.info.name,
                            provider: auth.provider,
                            uid:      auth.uid,
                            email:    auth.info.email,
                            avatar:   auth.info.image,
                            token:    auth.credentials.token,
                            password: Devise.friendly_token[0, 20])
       end
       user
   end
end

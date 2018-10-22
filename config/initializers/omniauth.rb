Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, "123160088358-us9vobbjvp0on8ie1vq16ffjn6mnumde.apps.googleusercontent.com", "VQhjA4YuRB4SqjES38kEYh96",
  scope: "https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/plus.me https://www.googleapis.com/auth/youtube"
end

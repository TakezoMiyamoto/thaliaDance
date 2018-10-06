
module WorksHelper
  def embed(youtube_url)
    if @work.youtube_url.present?
        youtube_id = youtube_url.split("=").last
        content_tag(:iframe, nil, src: "//www.youtube.com/embed/#{youtube_id}")
    end
  end

  def imaged(youtube_url)
    youtube_id = youtube_url.split("=").last
    img_tag("//img.youtube.com/vi/#{youtube_id}/mqdefault.jpg")
  end

  def img_tag(path)
      if path.blank?
        logger.error('InvalidImagePath path is blank')
        path = 'images/no_image.png'
      end
      image_tag path
    rescue StandardError
      logger.error("InvalidImagePath : #{path}")
      image_tag 'images/no_image.png'
    end

end

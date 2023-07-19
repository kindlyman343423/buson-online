class Admin::VideosController < Admin::ApplicationController
  # before_action :set_video, only: [:show, :create, :update]

  # GET /admin/videos
  def index
    connection = Faraday.new(
      url: "https://api.vimeo.com/me/projects/#{ENV["VIMEO_FOLDER_ID"]}/videos",
      headers: {'Authorization' => "Bearer #{ENV["VIMEO_ACCESS_TOKEN"]}"}
    ) do |builder|
      builder.response :json    
    end
    res = connection.get

    videos = res.body["data"].map do |video|
      {
        title: video["name"],
        player_embed_url: video["player_embed_url"],
        uploaded_at: video["release_time"],
        thumbnail_url: video["pictures"]["sizes"][3]["link"],
        description: video["description"],
        admin_url: "https://vimeo.com#{video["manage_link"]}" 
      }
    end

    render json: { videos: videos }, status: :ok
  end

  # # GET /admin/videos/1
  # def show
  # end

  # # POST /admin/videos/1
  # def create
  # end

  # # PATCH /admin/videos/1
  # def update
  # end

  private

  # def set_video
  #   @video = Video.find(params[:id])
  # end
end
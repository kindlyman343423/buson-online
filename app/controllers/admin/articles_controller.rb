class Admin::ArticlesController < Admin::ApplicationController
  before_action :set_article, only: [:show, :update, :destroy, :update_status]

  # GET /admin/articles
  def index
    articles = Article.order(created_at: "DESC").page(params[:page] || 1).per(30)
    data = {
      total_count: articles.total_count,
      total_pages: articles.total_pages,
      current_page: articles.current_page,
      articles: articles.map{ |article| article.simple_format }
    }
    render json: data, status: :ok
  end

  # GET /admin/articles/1
  def show
    render json: { article: @article.detail_format }, status: :ok
  end

  # POST /admin/articles
  def create
    article = Article.new(create_article_params)
    if article.save
      head :ok
    else
      render json: article.errors.full_messages, status: :unprocessable_entity
    end
  end

  # PATCH /admin/articles/1
  def update
    if @article.update(update_article_params)
      head :ok
    else
      render json: @article.errors.full_messages, status: :unprocessable_entity
    end
  end

  # DELETE /admin/articles/1
  def destroy
    @article.destroy
    head :ok
  end

  # PATCH /admin/articles/1/update_status
  def update_status
    if @article.update(status: params[:article][:status])
      head :ok
    else
      render json: @article.errors.full_messages, status: :unprocessable_entity
    end
  end

  private

  def set_article
    @article = Article.find(params[:id])
  end

  def create_article_params
    params.require(:article).permit(:title, :content, :status, :thumbnail)
  end

  def update_article_params
    params.require(:article).permit(:title, :content, :thumbnail)
  end
end
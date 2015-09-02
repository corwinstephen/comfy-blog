class Comfy::Admin::Blog::PostsController < Comfy::Admin::Blog::BaseController

  before_action :load_blog
  before_action :build_post, :only => [:new, :create]
  before_action :load_post,  :only => [:edit, :update, :destroy]

  def index
    @posts = comfy_paginate(@blog.posts.order(:published_at))
  end

  def new
    @post.author = ComfyBlog.config.default_author
    render
  end

  def create
    @post.save!
    flash[:success] = t('comfy.admin.blog.posts.created')
    redirect_to :action => :edit, :id => @post

  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = t('comfy.admin.blog.posts.create_failure')
    render :action => :new
  end

  def edit
    render
  end

  def update
    @post.update_attributes!(post_params)
    @post.tags = tags_from_params
    flash[:success] = t('comfy.admin.blog.posts.updated')
    redirect_to :action => :edit, :id => @post

  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = t('comfy.admin.blog.posts.update_failure')
    render :action => :edit
  end

  def destroy
    @post.destroy
    flash[:success] = t('comfy.admin.blog.posts.deleted')
    redirect_to :action => :index
  end

protected

  def load_post
    @post = @blog.posts.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = t('comfy.admin.blog.posts.not_found')
    redirect_to :action => :index
  end

  def build_post
    @post = @blog.posts.new(post_params)
    @post.published_at ||= Time.zone.now
    @post.tags = tags_from_params
  end

  def post_params
    the_post_params = params.fetch(:post, {})
    the_post_params.except(:tags).permit!
  end

  def tags_from_params
    post_params = params.fetch(:post, {})
    post_params.fetch(:tags, '').split(',').map do |tag|
      Comfy::Blog::Tag.find_or_create_by(name: tag.strip)
    end
  end

end

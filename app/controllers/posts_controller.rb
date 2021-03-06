class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  respond_to :html, :xml

  def index
    @posts = Post.all
    respond_with(@posts)
  end

  def show
    respond_with(@post)
  end

  def new
    @post = Post.new
    respond_with(@post)
  end

  def edit
  end

  def create
    @params = post_params
    @params[:postdate] = Time.now
    @post = current_user.posts.build(@params)
    if @post.save then
      puts 'creating post votes'
      @receivers = pickReceivers(@post.user_id, $number_of_sends_at_create_post)
      @receivers.each do |receiver|  
        @post_vote = PostVote.create(user_id: receiver.id, post_id: @post.id, vote: 0)
        @post_vote.save
      end
    end
    respond_with(@post)
  end

  def update
    @post.update(post_params)
    respond_with(@post)
  end

  def destroy
    @post.destroy
    respond_with(@post)
  end

  private
    def set_post
      @post = Post.find(params[:id])
    end

    def post_params
      params.require(:post).permit(:title, :description, :image, :upvotecount, :downvotecount, :postdate, :user_id)
    end

    def pickReceivers(post_owner, nrOfReceivers)
      # Ensure that potential receivers exludes owner of post
      potentialReceivers = User.where.not(id: post_owner)
      if potentialReceivers.count >= nrOfReceivers
        @receivers = potentialReceivers.sample(nrOfReceivers)
      elsif potentialReceivers.count < nrOfReceivers and potentialReceivers.count > 0
        @receivers = potentialReceivers.sample(potentialReceivers.count)
      end

      return @receivers
    end
end

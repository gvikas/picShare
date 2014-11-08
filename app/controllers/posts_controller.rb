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
    #@post = Post.new(post_params)
    #@post.user = current_user
    @post = current_user.posts.build(post_params)
    @post.save
    @users = pickNewReceivers(@post.user_id, @post.id, 4)
    @users.each do |user|  
      @post_vote = PostVote.create(user_id: user.id, post_id: @post.id, vote: 0)
      @post_vote.save
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
      params.require(:post).permit(:title, :description, :image_url, :upvotecount, :downvotecount, :postdate, :user_id)
    end

    def pickNewReceivers(post_owner, post_id, nrOfReceivers)
      @postVotes = PostVote.where(post_id: post_id)
      @alreadyReceived = @postVotes.map {|postVote| postVote.user_id}

      @potentialReceivers = User.where.not(id: @alreadyReceived)
      
      # Creator of post is marked, to ensure it does not get the its own post
      @potentialReceivers.each do |receiver|
        if receiver.id == post_owner
          @potentialReceivers.delete(receiver)
        end
      end

      @receivers = @potentialReceivers.sample(nrOfReceivers)
      return @receivers
    end
end

class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy, :new]
  before_action :correct_user, only: :destroy

  def new
    @micropost = Micropost.new
  end

  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    redirect_to request.referrer || root_url
    #request.referrer 一つ前に戻る
    #redirect_back(fallback_location: root_url)
    #同じ動きをする
  end

  def index
    @microposts = Micropost.paginate(page: params[:page])
  end

  private

    def micropost_params
      params.require(:micropost).permit(:content,:picture, :price, :rating)
    end

    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end

end

class UsersController < ApplicationController
before_filter :signed_in_user,	only: [:index, :edit, :update, :destroy]
before_filter :correct_user,	only: [:edit, :update]
before_filter :admin_user,		only: :destroy
  
  def index
	@users = User.paginate(page: params[:page])
  end
  
  def new
	@user = User.new
  end
  
  def destroy
	User.find(params[:id]).destroy
	flash[:success] = "User destroyed."
	redirect_to users_url
  end
  
  def show
	@user = User.find(params[:id])
	@trade = @user.trades.build
	@trades = @user.trades.current.paginate(page: params[:page])
	respond_to do |format|
		format.html
		format.json { 
			@user.password_digest = ""
			@user.remember_token = ""
			render json: @user
		}
	end
  end
  
  def create
	@user = User.new(params[:user])
	if @user.save
		sign_in @user
		flash[:success] = "Welcome to FireTrades!"
		redirect_to @user
	else
		render 'new'
	end
  end
  
  def edit
  end
  
  def update
	if @user.update_attributes(params[:user])
		flash[:success] = "Profile updated"
		sign_in @user
		redirect_to @user
	else
		render 'edit'
	end
  end
  
  private
	
	def correct_user
		@user = User.find(params[:id])
		redirect_to(root_path) unless current_user?(@user)
	end
	
end

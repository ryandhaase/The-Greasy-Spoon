class RestaurantsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_restaurant, only: [:show, :edit, :update, :destroy]
  before_action :check_user, except: [:index, :show]

  def index
    @restaurants = Restaurant.all.order('created_at DESC')
                   .paginate(page: params[:page], per_page: 5)
  end

  def show
    @reviews = Review.where(restaurant_id: @restaurant.id)
               .order('created_at DESC')
    if @reviews.blank?
      @avg_rating = 0
    else
      @avg_rating = @reviews.average(:rating).round(2)
    end
  end

  def new
    @restaurant = Restaurant.new
  end

  def edit
  end

  def create
    @restaurant = Restaurant.new(restaurant_params)

    respond_to do |format|
      if @restaurant.save
        format.html do
          redirect_to @restaurant,
                      notice: 'Restaurant was successfully created.'
        end
        format.json { render :show, status: :created, location: @restaurant }
      else
        format.html { render :new }
        format.json do
          render json: @restaurant.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def update
    respond_to do |format|
      if @restaurant.update(restaurant_params)
        format.html do
          redirect_to @restaurant,
                      notice: 'Restaurant was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @restaurant }
      else
        format.html { render :edit }
        format.json do
          render json: @restaurant.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @restaurant.destroy
    respond_to do |format|
      format.html do
        redirect_to restaurants_url,
                    notice: 'Restaurant was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  def search
    if params[:search].present?
      @restaurants = Restaurant.paginate(page: params[:page], per_page: 10)
                     .search(params[:search])
    else
      @restaurants = Restaurant.all.paginate(page: params[:page], per_page: 10)
    end
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:id])
  end

  def restaurant_params
    params.require(:restaurant)
      .permit(:name, :address, :phone, :website, :image)
  end

  def check_user
    return if current_user.admin?
    redirect_to root_url, alert: 'Sorry, only admins can do that!'
  end
end

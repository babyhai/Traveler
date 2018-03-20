class GuestReviewsController < ApplicationController
  # after_action :re_back, only: [:create, :destroy]

  def create
    # check if the reservation exist?
    @reservation = Reservation.where(
                    id: guest_review_params[:reservation_id],
                    room_id: guest_review_params[:room_id]
                   ).first
    if @reservation.nil? || @reservation.room.user.id != guest_review_params[:host_id].to_i
      p "---------"
      p @reservation
      p @reservation.room.user.id
      p guest_review_params[:host_id].to_i
      flash[:alert] = "未找到此预订."
      re_back
      return
    end

    # check if the current host already reviewed the guest in this reservation.
    @has_reviewed = GuestReview.where(
                      reservation_id: @reservation.id,
                      host_id: guest_review_params[:host_id]
                    ).first
    if !@has_reviewed.nil?
      flash[:alert] = "已经审核!"
      re_back
      return
    end

    @guest_review = current_user.guest_reviews.build(guest_review_params)
    p "---------"
    p @guest_review
    @guest_review.save
    flash[:success] = "评论以创建..."
    re_back
  end

  def destroy
    @guest_review = Review.find(params[:id])
    @guest_review.destroy
    flash[:success] = "评论已删除..."
    re_back
  end

  private
    def re_back
      redirect_back(fallback_location: request.referer)
    end

    def guest_review_params
      params.require(:guest_review).permit(:comment, :star, :room_id, :reservation_id, :host_id)
    end
end
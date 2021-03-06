module Forem
  class ForumsController < Forem::ApplicationController
    load_and_authorize_resource :only => :show
    helper 'forem/topics'

    def index
      @categories = Forem::Category.all
    end

    def show
      @forum = Forem::Forum.find(params[:id])
      @topics = if forem_admin? || @forum.moderator?(forem_user)
        @forum.topics
      else
        @forum.topics.visible.approved_or_pending_review_for(forem_user)
      end

      @topics = @topics.by_pinned_or_most_recent_post.page(params[:page]).per(20)

      respond_to do |format|
        format.html
        format.atom { render :layout => false }
      end
    end
  end
end

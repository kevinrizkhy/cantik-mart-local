class ActivitiesController < ApplicationController
  
	def index
		@models = PublicActivity::Activity.pluck(:trackable_type)
	  	@activities = PublicActivity::Activity.order("created_at desc").page param_page
		
		@date_search = DateTime.now.to_date
		if params[:activity].present?
			@date_search = params[:activity][:date_search] 
			@access_levels = params[:activity][:access_levels] 
			@targets = params[:activity][:targets]
		end
		if @date_search.present?
			@activities = @activities.where(created_at: @date_search)
		end

		if @access_levels.present?
			users = User.where(level: @access_levels).pluck(:id)
			@activities = @activities.where(owner_id: users)
		end

		if @targets.present?
			@activities = @activities.where(trackable_type: @targets)
		end
		# @activities.delete_all
	end

	private
		def param_page
			params[:page]
		end

end

class ActivitiesController < ApplicationController
  
	def index
		
		@models = Controller.all.pluck(:name)
	  	@activities = PublicActivity::Activity.order("created_at desc").page param_page
		
		@date_search = params[:activity][:date_search]
		@access_levels = params[:activity][:access_levels]
		@targets = params[:activity][:targets]
		
		if @date_search.present?
			@activities = @activities.where(created_at: @date_search)
		end

		if @access_levels.present?
			
		end

		if @targets.present?
		end
		binding.pry
		# @activities.delete_all
	end

	private
		def param_page
			params[:page]
		end

end

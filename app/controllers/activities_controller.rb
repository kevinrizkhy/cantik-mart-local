class ActivitiesController < ApplicationController
  
	def index
		@models = Controller.all.pluck(:name)
	  	@activities = PublicActivity::Activity.order("created_at desc").page param_page
		# @activities.delete_all
	end

	private
		def param_page
			params[:page]
		end

end

class GetsController < ApplicationController
	def index
		 json_result = {}
		 render :json =>json_result if params[:type].nil? || params[:last].nil?
		 store = Store.find_by(id: params[:type])
		 last_update = params[:last].to_date
		 binding.pry
		 render :json =>json_result if store.nil?
		 json_result["stores"] = Store.where("updated_at >= ?", last_update)
		 json_result["users"] = User.where("updated_at >= ?", last_update)
		 json_result["departments"] = Department.where("updated_at >= ?", last_update)
		 json_result["item_cats"] = ItemCat.where("updated_at >= ?", last_update)
		 json_result["items"] = Item.where("updated_at >= ?", last_update)
		 json_result["stocks"] = StoreItem.where(store: store).where("updated_at >= ?", last_update)
		 json_result["grocers"] = GrocerItem.where("updated_at >= ?", last_update)
		 render :json => json_result
	end
end
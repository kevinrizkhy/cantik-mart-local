class GetsController < ApplicationController
	def index
		 json_result = {}
		 json_result["stores"] = Store.all
		 json_result["users"] = User.all
		 json_result["departments"] = Department.all
		 json_result["item_cats"] = ItemCat.all
		 json_result["items"] = Item.all
		 json_result["stocks"] = StoreItem.all
		 render :json => json_result
	end
end
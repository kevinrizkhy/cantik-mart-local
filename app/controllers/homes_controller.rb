class HomesController < ApplicationController
  before_action :require_login
  require 'json'
  def index
    @total_limit_items = StoreItem.where(store_id: current_user.store.id).where('stock < min_stock').count
    @total_orders = Order.where(store_id: current_user.store.id).where('date_receive is null').count
    @total_payments = Order.where(store_id: current_user.store.id).where('date_receive is not null and date_paid_off is null').count
    @total_returs = Retur.where(store_id: current_user.store.id).where('date_picked is not null').count
  	# UserMailer.welcome_email("kevin.rizkhy85@gmail.com", "Subject 1").deliver
  	get_data
  end

  def get_data
	url = URI.parse('http://localhost/getData.php')
	req = Net::HTTP::Get.new(url.to_s)
	res = Net::HTTP.start(url.host, url.port) {|http|
	  http.request(req)
	}
	return if res.code != "200"
	datas = JSON.parse(res.body)
	datas.each_with_index do |data, index|
		next if data==datas.first || data==datas.last
		user_id = data["pin"]
		check_type = data["status"]
		date_tiem = data["waktu"]
	end
	puts datas
  end

  private

end

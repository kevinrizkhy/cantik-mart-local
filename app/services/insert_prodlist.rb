require 'roo'

class InsertProdlist
	
	def initialize
	end

	def read
		xlsx = Roo::Spreadsheet.open('./listprod.xlsx', extension: :xlsx)
		xlsx.each do |row|
			code = row[0]
			name = row[1]
			buy = row[3]
			sell = row[4]
			wholesale = row[5]
			box = row[6]
			# cat_id = row[7]
			cat_id = ItemCat.first.id

			brand = row[1].split[0]
			# brand = "DEFAULT BRAND"
 			insert_prod code, name, buy, sell, wholesale, box, cat_id, brand
		end
	end

	def insert_prod code, name, buy, sell, wholesale, box, cat_id, brand
		a = Item.create code: code, name: name, buy: buy, 
		sell: sell, wholesale: wholesale, box: box, 
		item_cat_id: cat_id, brand: brand
	end

	def update_brand
		items = Item.all
		items.each do |item|
			brand_name = item.name.split[0]
			item.brand  = brand_name
			item.save!
		end
	end
end
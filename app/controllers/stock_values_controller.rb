class StockValuesController < ApplicationController
  before_action :require_login
  before_action :require_fingerprint

  def index
    label_type = "month"
    numbers = 3
    end_date = DateTime.now.to_date
    start_date = DateTime.now.to_date - 3.months
    finances = StockValue.all
    check_prev_stock_value
    labels = generate_label label_type, numbers, start_date, end_date
    gon.labels = labels

    datasets = []
    datasets << stock_chart(labels, finances,label_type)
    gon.datasets = datasets
    @finances = finances.page param_page
  end

  def generate_label label_type, numbers, start_date, end_date
    labels = []
    if label_type == "month"
      start_date = start_date + 1.month
      numbers.times do |index|
        m = start_date + index.months
        labels << m.strftime("%B %Y") 
      end
    end
    labels
  end

  def check_prev_stock_value
    user = current_user
    store = user.store
    date_created = DateTime.now
    current_month = Date.today.month
    current_year = Date.today.year
    current_stock_value = StockValue.find_by("date_created > ? AND date_created < ?", Time.now.beginning_of_month, Time.now.end_of_month)
    stock_values = StoreItem.where(store: current_user.store)
    values = 0
    stock_values.each do |store_item|
      values += store_item.stock.to_f * store_item.item.buy.to_f 
    end
    description = "Stock Values ("+Date.today.strftime("%B")+" "+current_year.to_s+")"
    if current_stock_value.nil?
      StockValue.create user: user, store: store, nominal: values, date_created: date_created, description: description
      current_stock_value.nominal = values
      current_stock_value.date_created =  DateTime.now
      current_stock_value.save!
    end
  end

  def stock_chart labels, finances, label_type
    stock_datas = Array.new(labels.size) {|i| 0 }
    if label_type == "month"
      taxes = finances.group("date_trunc('month', date_created)").sum(:nominal) if label_type == "month"
      taxes.each_with_index do |debt, index|
        index_month = labels.index(debt[0].to_date.strftime("%B %Y")) if label_type == "month"
        index_month = labels.index(debt[0].to_date) if label_type == "day"
        index_month = labels.index(debt[0].at_beginning_of_week.strftime("%U").to_i+1) if label_type == "week"
        stock_datas[index_month] += debt[1].to_i.abs if index_month.present?
        stock_datas[0] += debt[1].to_i.abs if debt[1].nil?
      end
    else
      taxes = finances.where(finance_type: CashFlow::TAX).group("date_trunc('month', date_created)").sum(:nominal) if label_type == "day" || label_type == "week"
    end
    data = {
        label: 'Nilai Stok',
        data: stock_datas,
        backgroundColor: [
          'rgba(153, 102, 255, 0.2)',
        ],
        borderColor: [
          'rgba(153, 102, 255, 1)',
        ],
        borderWidth: 2
      }
  end

  private
    def param_page
      params[:page]
    end
end
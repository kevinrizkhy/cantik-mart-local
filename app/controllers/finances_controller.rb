class FinancesController < ApplicationController
  before_action :require_login

  def index
  	label_type = "day"
  	numbers = 3
  	end_date = DateTime.now.to_date
  	start_date = DateTime.now.to_date - 2.weeks
    check_prev
  	@finances = CashFlow.page param_page

  	labels = generate_label label_type, numbers, start_date, end_date
    gon.labels = labels

    datasets = []
    datasets << debt_chart(labels, @finances,label_type)
    datasets << cash_chart(labels, @finances,label_type)
    datasets << credit_chart(labels, @finances,label_type)
    datasets << tax_chart(labels, @finances,label_type)
    datasets << operational_chart(labels, @finances,label_type)
    datasets << stock_value_chart(labels, @finances,label_type)
    datasets << fix_cost_chart(labels, @finances,label_type)
    gon.datasets = datasets
  end

  def check_prev
    user = current_user
    store = user.store
    date_created = DateTime.now
    current_month = Date.today.month
    current_year = Date.today.year
    last_stock_value = CashFlow.where(finance_type: CashFlow::STOCK_VALUE)
    current_stock_value = CashFlow.where("date_created > ? AND date_created < ? AND finance_type = ?", Time.now.beginning_of_month, Time.now.end_of_month, CashFlow::STOCK_VALUE)
    stock_values = StoreItem.where(store: current_user.store)
    values = 0
    stock_values.each do |store_item|
      values += store_item.stock.to_f * store_item.item.buy.to_f 
    end
    description = "Stock Values ("+Date.today.strftime("%B")+" "+current_year.to_s+")"
    if current_stock_value.empty?
      CashFlow.create user: user, store: store, nominal: values, date_created: date_created, description: description, finance_type: CashFlow::STOCK_VALUE
    else
      current_stock_value = current_stock_value.first
      current_stock_value.nominal = values
      current_stock_value.date_created =  DateTime.now
      current_stock_value.save!
    end
  end

  def generate_label label_type, numbers, start_date, end_date
    labels = []
    if label_type == "month"
      start_date = start_date + 1.month
      numbers.times do |index|
        m = start_date + index.months
        labels << m.strftime("%B %Y") 
      end
    elsif label_type == "day"
      days = (start_date..end_date)
      days.each do |date|
        labels << date.to_date
      end
    else
      start_week = start_date.strftime("%U").to_i+1
      end_week = end_date.strftime("%U").to_i+1
      if start_date.year == end_date.year
        weeks = (start_week..end_week)
        weeks.each do |week|
          labels << week
        end
      else
        last_year_end_week = ("31-12-"+end_date.year.to_s).to_date.strftime("%U").to_i+1
        new_year_start_week = 1
        weeks = (start_week..last_year_end_week)
        weeks.each do |week|
          labels << week
        end
        weeks = (1..end_week)
        weeks.each do |week|
          labels << week
        end
      end
    end
    labels
  end

  def debt_chart labels, finances, label_type
  	debt_data = Array.new(labels.size) {|i| 0 }
  	debts = finances.where(finance_type: CashFlow::DEBT).group("DATE(date_created)").sum(:nominal) if label_type == "day" || label_type == "week"
    debts = finances.where(finance_type: CashFlow::DEBT).group("date_trunc('month', date_created)").sum(:nominal) if label_type == "month"
    debts.each_with_index do |debt, index|
      index_month = labels.index(debt[0].to_date.strftime("%B %Y")) if label_type == "month"
      index_month = labels.index(debt[0].to_date) if label_type == "day"
      index_month = labels.index(debt[0].at_beginning_of_week.strftime("%U").to_i+1) if label_type == "week"
      debt_data[index_month] += debt[1].to_i
    end
    debt_dates = debts.keys
  	sum_finances_before_date = Debt.where("date_created < ?", debt_dates.min).sum(:deficiency).to_i
      data = {
        label: 'Hutang',
        # data: (replace_zero_nominal debt_data, sum_finances_before_date),
        data: debt_data,
        backgroundColor: [
            'rgba(255, 99, 132, 0.2)',
          ],
        borderColor: [
            'rgba(255,99,132,1)',
        ],
        borderWidth: 2
      }
  end

  def cash_chart labels, finances, label_type
    cash_datas = Array.new(labels.size) {|i| 0 }
    cashes = finances.where(finance_type: CashFlow::CASH).group("DATE(date_created)").sum(:nominal) if label_type == "day" || label_type == "week"
    cashes = finances.where(finance_type: CashFlow::CASH).group("date_trunc('month', date_created)").sum(:nominal) if label_type == "month"
    cashes.each_with_index do |debt, index|
      index_month = labels.index(debt[0].to_date.strftime("%B %Y")) if label_type == "month"
      index_month = labels.index(debt[0].to_date) if label_type == "day"
      index_month = labels.index(debt[0].at_beginning_of_week.strftime("%U").to_i+1) if label_type == "week"
      cash_datas[index_month] += debt[1].to_i
    end
    cash_dates = cashes.keys
    sum_finances_before_date = Credit.where("date_created < ?", cash_dates.min).sum(:nominal).to_i
      data = {
        label: 'Kas',
        data: (sum_this_month cash_datas),
        backgroundColor: [
          'rgba(54, 162, 235, 0.2)',
        ],
        borderColor: [
          'rgba(54, 162, 235, 1)',
        ],
        borderWidth: 2
      }
  end

  def credit_chart labels, finances, label_type
    credit_datas = Array.new(labels.size) {|i| 0 }
    credits = finances.where(finance_type: CashFlow::CREDIT).group("DATE(date_created)").sum(:nominal) if label_type == "day" || label_type == "week"
    credits = finances.where(finance_type: CashFlow::CREDIT).group("date_trunc('month', date_created)").sum(:nominal) if label_type == "month"
    credits.each_with_index do |debt, index|
      index_month = labels.index(debt[0].to_date.strftime("%B %Y")) if label_type == "month"
      index_month = labels.index(debt[0].to_date) if label_type == "day"
      index_month = labels.index(debt[0].at_beginning_of_week.strftime("%U").to_i+1) if label_type == "week"
      credit_datas[index_month] += debt[1].to_i
    end
    credit_dates = credits.keys
    sum_finances_before_date = Credit.where("date_created < ?", credit_dates.min).sum(:deficiency).to_i
    data = {
      label: 'Pemasukkan',
      # data: replace_zero_nominal(receivables_data, sum_finances_before_date, Finance::RECEIVABLES),
      data: credit_datas,
      backgroundColor: [
          'rgba(255, 206, 86, 0.2)',
        ],
      borderColor: [
          'rgba(255, 206, 86, 1)',
        ],
      borderWidth: 2
    }
  end

  def fix_cost_chart labels, finances, label_type
    fix_cost_datas = Array.new(labels.size) {|i| 0 }
    fix_costs = finances.where(finance_type: CashFlow::FIX_COST).group("DATE(date_created)").sum(:nominal) if label_type == "day" || label_type == "week"
    fix_costs = finances.where(finance_type: CashFlow::FIX_COST).group("date_trunc('month', date_created)").sum(:nominal) if label_type == "month"
    fix_costs.each_with_index do |debt, index|
      index_month = labels.index(debt[0].to_date.strftime("%B %Y")) if label_type == "month"
      index_month = labels.index(debt[0].to_date) if label_type == "day"
      index_month = labels.index(debt[0].at_beginning_of_week.strftime("%U").to_i+1) if label_type == "week"
      fix_cost_datas[index_month] += debt[1].to_i
    end
    credit_dates = fix_costs.keys
    sum_finances_before_date = Credit.where("date_created < ?", credit_dates.min).sum(:deficiency).to_i
    data = {
      label: 'Biaya Pasti',
      # data: replace_zero_nominal(receivables_data, sum_finances_before_date, Finance::RECEIVABLES),
      data: fix_cost_datas,
      backgroundColor: [
          'rgba(141, 110, 99, 0.2)',
        ],
      borderColor: [
          'rgba(141, 110, 99, 1)',
        ],
      borderWidth: 2
    }
  end

  def stock_value_chart labels, finances, label_type
    stock_value_datas = Array.new(labels.size) {|i| 0 }
    stock_values = finances.where(finance_type: CashFlow::STOCK_VALUE).group("DATE(date_created)").sum(:nominal) if label_type == "day" || label_type == "week"
    stock_values = finances.where(finance_type: CashFlow::STOCK_VALUE).group("date_trunc('month', date_created)").sum(:nominal) if label_type == "month"
    stock_values.each_with_index do |debt, index|
      index_month = labels.index(debt[0].to_date.strftime("%B %Y")) if label_type == "month"
      index_month = labels.index(debt[0].to_date) if label_type == "day"
      index_month = labels.index(debt[0].at_beginning_of_week.strftime("%U").to_i+1) if label_type == "week"
      stock_value_datas[index_month] += debt[1].to_i
    end
    credit_dates = stock_values.keys
    data = {
      label: 'Nilai Stok',
      data: (replace_zero_nominal stock_value_datas),
      backgroundColor: [
          'rgba(75, 192, 192, 0.2)',
        ],
      borderColor: [
          'rgba(75, 192, 192, 1)',
        ],
      borderWidth: 2
    }
  end

  def tax_chart labels, finances, label_type
    tax_datas = Array.new(labels.size) {|i| 0 }
    if label_type == "month"
      taxes = finances.where(finance_type: CashFlow::TAX).group("date_trunc('month', date_created)").sum(:nominal) if label_type == "month"
      taxes.each_with_index do |debt, index|
        index_month = labels.index(debt[0].to_date.strftime("%B %Y")) if label_type == "month"
        index_month = labels.index(debt[0].to_date) if label_type == "day"
        index_month = labels.index(debt[0].at_beginning_of_week.strftime("%U").to_i+1) if label_type == "week"
        tax_datas[index_month] += debt[1].to_i
      end
    else
      taxes = finances.where(finance_type: CashFlow::TAX).group("date_trunc('month', date_created)").sum(:nominal) if label_type == "day" || label_type == "week"
    end
    data = {
        label: 'Pajak',
        data: tax_datas,
        backgroundColor: [
          'rgba(153, 102, 255, 0.2)',
        ],
        borderColor: [
          'rgba(153, 102, 255, 1)',
        ],
        borderWidth: 2
      }
  end

  def operational_chart labels, finances, label_type
    operational_datas = Array.new(labels.size) {|i| 0 }
    operationals = finances.where(finance_type: CashFlow::OPERATIONAL).group("DATE(date_created)").sum(:nominal) if label_type == "day" || label_type == "week"
    operationals = finances.where(finance_type: CashFlow::OPERATIONAL).group("date_trunc('month', date_created)").sum(:nominal) if label_type == "month"
    operationals.each_with_index do |debt, index|
      index_month = labels.index(debt[0].to_date.strftime("%B %Y")) if label_type == "month"
      index_month = labels.index(debt[0].to_date) if label_type == "day"
      index_month = labels.index(debt[0].at_beginning_of_week.strftime("%U").to_i+1) if label_type == "week"
      operational_datas[index_month] += debt[1].to_i
    end
    data = {
      label: 'Operasional',
      data: operational_datas,
      backgroundColor: [
          'rgba(255, 159, 64, 0.2)',
        ],
      borderColor: [
          'rgba(255, 159, 64, 1)',
        ],
      borderWidth: 2
    }
  end

  def sum_nominal datas, sum_finances_before_date
    datas.each_with_index do |data, index|
      rev_idx = datas.size-index-1
      (rev_idx).times do |r_idx|
        datas[rev_idx] += datas[r_idx] 
      end
    end 

    min = datas.max
    datas.each do |data|
      if data != 0 && min > data
        min = data
      end
    end
    datas = datas.map { |x| x += sum_finances_before_date }
    # datas = datas.map{|e| e < 0 ? 0 : e}
    datas
  end

  def replace_zero_nominal datas
    max = datas.max
    datas.each do |data|
      if data == 0
        data = max
      end
    end
  end

  def sum_this_month datas
    datas.each_with_index do |data, index|
      rev_idx = datas.size-index-1
      (rev_idx).times do |r_idx|
        datas[rev_idx] += datas[r_idx] 
      end
    end 
    datas
  end

  def new
  end

  def create
    finance_type = params[:finance][:finance_type]
    nominal = params[:finance][:nominal].to_f
    description = params[:finance][:description]
    date_created = DateTime.now
    user = current_user
    store = current_user.store
    finance_types = []
    if finance_type == "Outcome" 
      Cash.create user: user, store: store, nominal: nominal*-1, date_created: date_created, description: description
      Credit.create user: user, store: store, nominal: nominal, date_created: date_created, description: description, 
                    finance_type: Credit::OTHER, deficiency:nominal
      finance_types = [[CashFlow::CASH, nominal*-1], [CashFlow::CREDIT, nominal]]
    elsif finance_type == "Income"
      Cash.create user: user, store: store, nominal: nominal, date_created: date_created, description: description
      finance_types = [[CashFlow::CASH, nominal]]
    elsif finance_type == "Operational"
      finance_types = [[CashFlow::OPERATIONAL, nominal*-1]]
    elsif finance_type == "Tax"
      description = "TAX "+(DateTime.now-1.month).strftime("%B")+"/"+Date.today.year.to_s + " ("+description+")"
      date_created = Date.today.beginning_of_month
      finance_types = [[CashFlow::TAX, nominal*-1]]
    elsif finance_type == "Fix_Cost"
      finance_types = [[CashFlow::FIX_COST, nominal*-1]]
    end
    finance_types.each_with_index do |finance_type|
      if finance_type[0] == CashFlow::TAX
        tax_current_month = CashFlow.find_by("date_created > ? AND date_created < ? AND finance_type = ?", Time.now.beginning_of_month, Time.now.end_of_month, CashFlow::TAX)
        if tax_current_month.present?
          tax_current_month.nominal = nominal
          tax_current_month.date_created = DateTime.now
          tax_current_month.save!
          break
        end
      end
      CashFlow.create user: user, store: store, nominal: finance_type[1], date_created: date_created, description: description, finance_type: finance_type[0]
    end
    return redirect_to finances_path
  end

  private
    def param_page
      params[:page]
    end
end
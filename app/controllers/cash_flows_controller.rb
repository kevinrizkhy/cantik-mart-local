class CashFlowsController < ApplicationController
  before_action :require_login
  before_action :require_fingerprint

  def index
  	label_type = "day"
  	numbers = 3
  	end_date = DateTime.now.to_date+1.day
  	start_date = DateTime.now.to_date - 2.weeks
    check_prev
  	@finances = CashFlow.where("date_created > ? AND date_created < ?", start_date, end_date)
  	labels = generate_label label_type, numbers, start_date, end_date
    gon.labels = labels
    datasets = []
    datasets << debt_chart(labels, @finances,label_type)
    datasets << cash_chart(labels, @finances,label_type)
    datasets << receivable_chart(labels, @finances,label_type)
    datasets << tax_chart(labels, @finances,label_type)
    datasets << operational_chart(labels, @finances,label_type)
    # datasets << stock_value_chart(labels, @finances,label_type)
    datasets << fix_cost_chart(labels, @finances,label_type)
    gon.datasets = datasets
    @finances = @finances.order("date_created DESC")
    @finances = @finances.page param_page
  end

  def check_prev
    check_prev_stock_value
    check_prev_trx
  end

  def check_prev_trx
    start_date = DateTime.now.to_date
    end_date = DateTime.now.to_date - 1.day
    
    last_trx = "01-01-1999".to_date
    last_trx = Transaction.last.date_created.to_date if Transaction.last.present?
    
    checking_trx_finance = CashFlow.where(finance_type: CashFlow::TRANSACTIONS).last
    start_date = checking_trx_finance.date_created if checking_trx_finance.present?
    start_date = "01-01-1999".to_date if checking_trx_finance.nil?

    transactions = Transaction.where("date_created > ? AND date_created < ?", start_date, end_date).group("DATE(date_created)").sum(:grand_total)
    based_prices = Transaction.where("date_created > ? AND date_created < ?", start_date, end_date).group("DATE(date_created)").sum(:hpp_total)

    a = transactions
    b = based_prices
    trx_based =  a.merge!(b) { |k, o, n| k=o,k=n,k=o - n }
    trx_based.each do |transaction|
      if CashFlow.find_by(invoice: "TRX-"+transaction[0].to_s).nil?  
        a = CashFlow.create date_created: transaction[0].to_date, nominal: transaction[1][0], user: current_user, 
        store: current_user.store, description: "TRX "+transaction[0].to_s, finance_type: CashFlow::TRANSACTIONS,
        invoice: "TRX-"+transaction[0].to_s
        # b = CashFlow.create date_created: transaction[0].to_date, nominal: transaction[1][1], user: current_user, 
        # store: current_user.store, description: "HPP "+transaction[0].to_s, finance_type: CashFlow::HPP
        # c = CashFlow.create date_created: transaction[0].to_date, nominal: transaction[1][2], user: current_user, 
        # store: current_user.store, description: "PRF "+transaction[0].to_s, finance_type: CashFlow::PROFIT
        ProfitLoss.create date_created: transaction[0].to_date, nominal: transaction[1][2], user: current_user, 
        store: current_user.store, description: "PRF "+transaction[0].to_s, finance_type: ProfitLoss::PROFIT
      end
    end
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
  	debts = finances.where(finance_type: CashFlow::BANK_LOAN).group("DATE(date_created)").sum(:nominal) if label_type == "day" || label_type == "week"
    debts = finances.where(finance_type: CashFlow::BANK_LOAN).group("date_trunc('month', date_created)").sum(:nominal) if label_type == "month"
    debts.each_with_index do |debt, index|
      index_month = labels.index(debt[0].to_date.strftime("%B %Y")) if label_type == "month"
      index_month = labels.index(debt[0].to_date) if label_type == "day"
      index_month = labels.index(debt[0].at_beginning_of_week.strftime("%U").to_i+1) if label_type == "week"
      debt_data[index_month] += debt[1].to_i.abs
    end
    debt_dates = debts.keys
  	sum_finances_before_date = Debt.where("date_created < ?", debt_dates.min).sum(:deficiency).to_i
      data = {
        label: 'Hutang',
        data: (sum_nominal debt_data, sum_finances_before_date),
        # data: debt_data,
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
    cashes = finances.group("DATE(date_created)").sum(:nominal) if label_type == "day" || label_type == "week"
    cashes = finances.group("date_trunc('month', date_created)").sum(:nominal) if label_type == "month"
    cashes.each_with_index do |debt, index|
      index_month = labels.index(debt[0].to_date.strftime("%B %Y")) if label_type == "month"
      index_month = labels.index(debt[0].to_date) if label_type == "day"
      index_month = labels.index(debt[0].at_beginning_of_week.strftime("%U").to_i+1) if label_type == "week"
      cash_datas[index_month] += debt[1].to_i  if index_month.present?
      cash_datas[0] += debt[1].to_i if index_month.nil?
    end
    cash_dates = cashes.keys
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

  def receivable_chart labels, finances, label_type
    receivable_datas = Array.new(labels.size) {|i| 0 }
    receivables = finances.where(finance_type: CashFlow::EMPLOYEE_LOAN).group("DATE(date_created)").sum(:nominal) if label_type == "day" || label_type == "week"
    receivables = finances.where(finance_type: CashFlow::EMPLOYEE_LOAN).group("date_trunc('month', date_created)").sum(:nominal) if label_type == "month"
    receivables.each_with_index do |debt, index|
      index_month = labels.index(debt[0].to_date.strftime("%B %Y")) if label_type == "month"
      index_month = labels.index(debt[0].to_date) if label_type == "day"
      index_month = labels.index(debt[0].at_beginning_of_week.strftime("%U").to_i+1) if label_type == "week"
      receivable_datas[index_month] += debt[1].to_i.abs
    end
    receivable_dates = receivables.keys
    sum_finances_before_date = Receivable.where("date_created < ?", receivable_dates.min).sum(:deficiency).to_i
    data = {
      label: 'Piutang',
      data: (sum_nominal receivable_datas, sum_finances_before_date),
      # data: receivable_datas,
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
      fix_cost_datas[index_month] += debt[1].to_i.abs
    end
    data = {
      label: 'Biaya Pasti',
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

  def tax_chart labels, finances, label_type
    tax_datas = Array.new(labels.size) {|i| 0 }
    if label_type == "month"
      taxes = finances.where(finance_type: CashFlow::TAX).group("date_trunc('month', date_created)").sum(:nominal) if label_type == "month"
      taxes.each_with_index do |debt, index|
        index_month = labels.index(debt[0].to_date.strftime("%B %Y")) if label_type == "month"
        index_month = labels.index(debt[0].to_date) if label_type == "day"
        index_month = labels.index(debt[0].at_beginning_of_week.strftime("%U").to_i+1) if label_type == "week"
        binding.pry
        tax_datas[index_month] += debt[1].to_i.abs if debt[1].present?
        tax_datas[0] += debt[1].to_i.abs if debt[1].nil?
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
      operational_datas[index_month] += debt[1].to_i.abs
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
    inv_number = Time.now.to_i.to_s
    if finance_type == "Loan" 
      invoice = " EL-"+inv_number
      # to_user==> di view blm ada, diisi employee
      Receivable.create user: user, store: store, nominal: nominal, date_created: date_created, description: description, 
                    finance_type: Receivable::EMPLOYEE, deficiency:nominal, to_user: 1
      CashFlow.create user: user, store: store, nominal: nominal*-1, date_created: date_created, description: description, 
                      finance_type: CashFlow::EMPLOYEE_LOAN, invoice: invoice
    elsif finance_type == "BankLoan"
      invoice = " BL-"+inv_number
      Debt.create user: user, store: store, nominal: nominal*-1, date_created: date_created, description: description,
                    finance_type: Debt::BANK, deficiency:nominal
      CashFlow.create user: user, store: store, nominal: nominal, date_created: date_created, description: description, 
                      finance_type: CashFlow::BANK_LOAN, invoice: invoice
    elsif finance_type == "Outcome"
      invoice = " OUT-"+inv_number
      CashFlow.create user: user, store: store, nominal: nominal*-1, date_created: date_created, description: description, 
                      finance_type: CashFlow::OUTCOME, invoice: invoice
    elsif finance_type == "Income"
      invoice = " IN-"+inv_number
      CashFlow.create user: user, store: store, nominal: nominal, date_created: date_created, description: description, 
                      finance_type: CashFlow::INCOME, invoice: invoice
    elsif finance_type == "Asset"
      invoice = " AST-"+inv_number
      CashFlow.create user: user, store: store, nominal: nominal, date_created: date_created, description: description, 
                      finance_type: CashFlow::ASSET, invoice: invoice
    elsif finance_type == "Operational"
      invoice = " OPR-"+inv_number
      CashFlow.create user: user, store: store, nominal: nominal*-1, date_created: date_created, description: description, 
                      finance_type: CashFlow::OPERATIONAL, invoice: invoice
    elsif finance_type == "Tax"
      description = "TAX "+(DateTime.now.month).strftime("%B")+"/"+Date.today.year.to_s + " ("+description+")"
      invoice = " TAX-"+inv_number
      date_created = Date.today.beginning_of_month
      tax_current_month = CashFlow.find_by("date_created > ? AND date_created < ? AND finance_type = ?", Time.now.beginning_of_month, Time.now.end_of_month, CashFlow::TAX)
      if tax_current_month.present?
        tax_current_month.nominal = nominal
        tax_current_month.date_created = DateTime.now
        tax_current_month.save!
      else
        CashFlow.create user: user, store: store, nominal: nominal*-1, date_created: date_created, description: description, 
                        finance_type: CashFlow::TAX, invoice: invoice
      end
    elsif finance_type == "Fix_Cost"
      invoice = " FIX-"+inv_number
      CashFlow.create user: user, store: store, nominal: nominal*-1, date_created: date_created, description: description, 
                      finance_type: CashFlow::FIX_COST, invoice: invoice
    end
    return redirect_success cash_flows_path
  end

  private
    def param_page
      params[:page]
    end
end
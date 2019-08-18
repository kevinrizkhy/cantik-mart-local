class CashFlowsController < ApplicationController
  before_action :require_login
  before_action :require_fingerprint

  def index
  	filter = filter_search
    @search = filter[0]
  	@finances = filter[1]
  end

  def check_prev
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

  def new
    @users = User.all
  end

  def create
    finance_type = params[:finance][:finance_type]
    nominal = params[:finance][:nominal].to_f.abs
    description = params[:finance][:description]
    date_created = DateTime.now
    user = current_user
    store = current_user.store
    finance_types = []
    to_user = params[:finance][:to_user]
    inv_number = Time.now.to_i.to_s
    if finance_type == "Loan" 
      invoice = " EL-"+inv_number
      # to_user==> di view blm ada, diisi employee
      receivable = Receivable.create user: user, store: store, nominal: nominal, date_created: date_created, description: description, 
                    finance_type: Receivable::EMPLOYEE, deficiency:nominal, to_user: to_user
      cash_flow = CashFlow.create user: user, store: store, nominal: nominal*-1, date_created: date_created, description: description, 
                      finance_type: CashFlow::EMPLOYEE_LOAN, invoice: invoice
      cash_flow.create_activity :create, owner: current_user
      receivable.create_activity :create, owner: current_user         
    elsif finance_type == "BankLoan"
      invoice = " BL-"+inv_number
      debt = Debt.create user: user, store: store, nominal: nominal*-1, date_created: date_created, description: description,
                    finance_type: Debt::BANK, deficiency:nominal
      cash_flow = CashFlow.create user: user, store: store, nominal: nominal, date_created: date_created, description: description, 
                      finance_type: CashFlow::BANK_LOAN, invoice: invoice
      cash_flow.create_activity :create, owner: current_user       
      debt.create_activity :create, owner: current_user           
    elsif finance_type == "Outcome"
      invoice = " OUT-"+inv_number
      cash_flow = CashFlow.create user: user, store: store, nominal: nominal*-1, date_created: date_created, description: description, 
                      finance_type: CashFlow::OUTCOME, invoice: invoice
      cash_flow.create_activity :create, owner: current_user         
    elsif finance_type == "Income"
      invoice = " IN-"+inv_number
      cash_flow = CashFlow.create user: user, store: store, nominal: nominal, date_created: date_created, description: description, 
                      finance_type: CashFlow::INCOME, invoice: invoice
      cash_flow.create_activity :create, owner: current_user         
    elsif finance_type == "Asset"
      invoice = " AST-"+inv_number
      cash_flow = CashFlow.create user: user, store: store, nominal: nominal, date_created: date_created, description: description, 
                      finance_type: CashFlow::ASSET, invoice: invoice
      cash_flow.create_activity :create, owner: current_user         
    elsif finance_type == "Operational"
      invoice = " OPR-"+inv_number
      cash_flow = CashFlow.create user: user, store: store, nominal: nominal*-1, date_created: date_created, description: description, 
                      finance_type: CashFlow::OPERATIONAL, invoice: invoice
      cash_flow.create_activity :create, owner: current_user         
    elsif finance_type == "Tax"
      description = "TAX "+Date::MONTHNAMES[Date.today.month]+"/"+Date.today.year.to_s + " ("+description+")"
      invoice = " TAX-"+inv_number
      date_created = Date.today.beginning_of_month
      tax_current_month = CashFlow.find_by("date_created > ? AND date_created < ? AND finance_type = ?", Time.now.beginning_of_month, Time.now.end_of_month, CashFlow::TAX)
      if tax_current_month.present?
        tax_current_month.nominal = nominal
        tax_current_month.date_created = DateTime.now
        tax_current_month.save!
        tax_current_month.create_activity :edit, owner: current_user         
      else
        cash_flow = CashFlow.create user: user, store: store, nominal: nominal*-1, date_created: date_created, description: description, 
                        finance_type: CashFlow::TAX, invoice: invoice
        cash_flow.create_activity :create, owner: current_user         
      end
    elsif finance_type == "Fix_Cost"
      invoice = " FIX-"+inv_number
      cash_flow = CashFlow.create user: user, store: store, nominal: nominal*-1, date_created: date_created, description: description, 
                      finance_type: CashFlow::FIX_COST, invoice: invoice
      cash_flow.create_activity :create, owner: current_user                
    end
    return redirect_success cash_flows_path, "Data Berhasil Disimpan"
  end

  private
    def param_page
      params[:page]
    end

    def filter_search
      results = []
      search_text = "Pencarian "
      filters = CashFlow.page param_page

      finance_types = params[:finance_type]
      if finance_types.present?
        finance_types = finance_types.map(&:to_i)
        if finance_types.size > 0
          if !finance_types.include? 0
            filters = filters.where(finance_type: finance_types)
            search_text+= "[" if finance_types.size > 1
            finance_types.each do |f_type|
              type = CashFlow.finance_types.key(f_type)
              if finance_types.last == f_type
                search_text+= type.upcase + "] " if finance_types.size > 1
                search_text+= type.upcase + " " if finance_types.size == 1
              else
                search_text+= type.upcase + ", "
              end
            end
          else
            search_text+= "SEMUA DATA "
          end
        end
      end

      switch_data_month_param = params[:switch_date_month]
      if switch_data_month_param == "month" 
        before_months = params[:months].to_i
        search_text += before_months.to_s + " bulan terakhir "
        start_months = (DateTime.now - before_months.months).beginning_of_month 
        filters = filters.where("date_created >= ?", start_months)
      else
        end_date = DateTime.now.to_date + 1.day
        start_date = DateTime.now.to_date - 1.weeks
        end_date = params[:end_date] if params[:end_date].present?
        start_date = params[:date_from] if params[:date_from].present?
        search_text += "dari " + start_date.to_s + " hingga " + end_date.to_s + " "
        filters = filters.where("date_created >= ? AND date_created <= ?", start_date, end_date)
      end

      if params[:order_by] == "asc"
        search_text+= "secara menaik"
        filters = filters.order("date_created ASC")
      else
        filters = filters.order("date_created DESC")
        search_text+= "secara menurun"
      end
      results << search_text
      results << filters
      return results
    end
end
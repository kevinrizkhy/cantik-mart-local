class FinancesController < ApplicationController
  before_action :require_login
  def index
    @search = "(Data 6bulan terakhir)"
    numbers = 6
    label_type = "month"
    end_date = DateTime.now
    start_date = DateTime.now - numbers.months
    @finances = Finance.page param_page
    if params[:finance_type].present? 
      if params[:finance_type] != "0"
        @finances = @finances.where(finance_type: params[:finance_type])
        @search = "(Pencarian "+Finance.finance_types.key(params[:finance_type].to_i).to_s+" "
      else
        @search = "(Pencarian "
      end
    end
    if params[:switch_date_month] == "date"
      if params[:date_from] != "" && params[:date_to] != ""
        from = params[:date_from].to_date
        to = params[:date_to].to_date
        if from > to
          temp = from
          from = to
          to = temp
        end
        @finances = @finances.where("date_created >= ? AND date_created <= ?", from, to+1.day)
        start_date = from
        end_date = to
        numbers = end_date.month - start_date.month 
        numbers = numbers * -1 if numbers < 0
        @search += " " + start_date.to_s+" - "+end_date.to_s+" "
        if numbers < 1
          label_type = "day"
        else
          label_type = "week"
        end
      end
    else
      numbers = params[:months].to_i if params[:months].present?
      start_date = end_date - numbers.months
      @finances = @finances.where("date_created >= ?", Date.today.beginning_of_month - numbers.months )
      @search += numbers.to_s+"bulan terakhir "
    end

    finances = @finances

    if params[:order_by].present?
      @finances = @finances.order("date_created "+params[:order_by])
      @search+= "secara menaik)" if params[:order_by] == "asc"      
      @search+= "secara menurun)" if params[:order_by] == "desc" 
    end
    labels = generate_label label_type, numbers, start_date, end_date
    gon.labels = labels
    gon.debt_data = js_debt labels, finances,label_type
    gon.operational_data = js_operational labels, finances,label_type
    gon.tax_data = js_tax labels, finances,label_type
    gon.receivables_data = js_receivables labels, finances,label_type
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

  def js_debt labels, finances, label_type
    debt_data = Array.new(labels.size) {|i| 0 }
    debts = finances.where("finance_type = ?", Finance::DEBT).group("DATE(date_created)").sum(:nominal) if label_type == "day" || label_type == "week"
    debts = finances.where("finance_type = ?", Finance::DEBT).group("date_trunc('month', date_created)").sum(:nominal) if label_type == "month"
    debts.each_with_index do |debt, index|
      index_month = labels.index(debt[0].to_date.strftime("%B %Y")) if label_type == "month"
      index_month = labels.index(debt[0].to_date) if label_type == "day"
      index_month = labels.index(debt[0].at_beginning_of_week.strftime("%U").to_i+1) if label_type == "week"
      total = debt[1].to_i
      index_month.times do |idx|
        total+= debt_data[idx]
      end
      debt_data[index_month] = total
    end 
    replace_zero_nominal debt_data
  end

  def js_operational labels, finances, label_type
    operational_data = Array.new(labels.size) {|i| 0 }
    operationals = finances.where("finance_type = ?", Finance::OPERATIONAL).group("DATE(date_created)").sum(:nominal) if label_type == "day" || label_type == "week"
    operationals = finances.where("finance_type = ?", Finance::OPERATIONAL).group("date_trunc('month', date_created)").sum(:nominal) if label_type == "month"
    operationals.each_with_index do |operational, index|
      index_month = labels.index(operational[0].to_date.strftime("%B %Y")) if label_type == "month"
      index_month = labels.index(operational[0].to_date) if label_type == "day"
      index_month = labels.index(operational[0].at_beginning_of_week.strftime("%U").to_i+1) if label_type == "week"
      total = operational[1].to_i
      index_month.times do |idx|
        total+= operational_data[idx]
      end
      operational_data[index_month] = total
    end 
    operational_data
  end

  def js_tax labels, finances, label_type
    tax_data = Array.new(labels.size) {|i| 0 }
    taxs = finances.where("finance_type = ?", Finance::TAX).group("DATE(date_created)").sum(:nominal) if label_type == "day" || label_type == "week"
    taxs = finances.where("finance_type = ?", Finance::TAX).group("date_trunc('month', date_created)").sum(:nominal) if label_type == "month"
    taxs.each_with_index do |tax, index|
      index_month = labels.index(tax[0].to_date.strftime("%B %Y")) if label_type == "month"
      index_month = labels.index(tax[0].to_date) if label_type == "day"
      index_month = labels.index(tax[0].at_beginning_of_week.strftime("%U").to_i+1) if label_type == "week"
      total = tax[1].to_i
      index_month.times do |idx|
        total+= tax_data[idx]
      end
      tax_data[index_month] = total
    end 
    tax_data
  end

  def js_receivables labels, finances, label_type
    receivables_data = Array.new(labels.size) {|i| 0 }
    receivables = finances.where("finance_type = ?", Finance::RECEIVABLES).group("DATE(date_created)").sum(:nominal) if label_type == "day" || label_type == "week"
    receivables = finances.where("finance_type = ?", Finance::RECEIVABLES).group("date_trunc('month', date_created)").sum(:nominal) if label_type == "month"
    receivables.each_with_index do |receivable, index|
      index_month = labels.index(receivable[0].to_date.strftime("%B %Y")) if label_type == "month"
      index_month = labels.index(receivable[0].to_date) if label_type == "day"
      index_month = labels.index(receivable[0].at_beginning_of_week.strftime("%U").to_i+1) if label_type == "week"
      total = receivable[1].to_i
      index_month.times do |idx|
        total+= receivables_data[idx]
      end
      receivables_data[index_month] = total
    end 
    replace_zero_nominal receivables_data
  end

  def replace_zero_nominal datas
    datas.each_with_index do |data, index|
      if data == 0 && index != 0
        datas[index] = datas[index-1]
      end
    end
    datas
  end

  def new
  end

  def create
    finance = Finance.new finance_params
    finance.date_created = DateTime.now
    finance.user = current_user
    finance.store = current_user.store
    return redirect_to new_user_path if finance.invalid?
    finance.save!
    return redirect_to finances_path
  end

  private
    def finance_params
      params.require(:finance).permit(
        :nominal, :description, :finance_type
      )
    end

    def param_page
      params[:page]
    end
end

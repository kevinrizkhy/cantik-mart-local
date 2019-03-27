class FixCostsController < ApplicationController
  before_action :require_login

  def index
  	label_type = "day"
  	numbers = 3
  	end_date = DateTime.now.to_date
  	start_date = DateTime.now.to_date - 2.weeks
  	finances = Receivable.all

  	labels = generate_label label_type, numbers, start_date, end_date
    gon.labels = labels

    datasets = []
    datasets << receivable_chart(labels, finances,label_type)
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

  def receivable_chart labels, finances, label_type
    receivable_datas = Array.new(labels.size) {|i| 0 }
    receivables = finances.group("DATE(date_created)").sum(:nominal) if label_type == "day" || label_type == "week"
    receivables = finances.group("date_trunc('month', date_created)").sum(:nominal) if label_type == "month"
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

  private
    def param_page
      params[:page]
    end
end
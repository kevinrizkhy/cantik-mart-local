class TaxsController < ApplicationController
  before_action :require_login

  def index
  	label_type = "month"
  	numbers = 3
  	end_date = DateTime.now.to_date
  	start_date = DateTime.now.to_date - 3.months
  	finances = CashFlow.where(finance_type: CashFlow::TAX)

  	labels = generate_label label_type, numbers, start_date, end_date
    gon.labels = labels

    datasets = []
    datasets << tax_chart(labels, finances,label_type)
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

  def tax_chart labels, finances, label_type
    tax_datas = Array.new(labels.size) {|i| 0 }
    if label_type == "month"
      taxes = finances.group("date_trunc('month', date_created)").sum(:nominal) if label_type == "month"
      taxes.each_with_index do |debt, index|
        index_month = labels.index(debt[0].to_date.strftime("%B %Y")) if label_type == "month"
        index_month = labels.index(debt[0].to_date) if label_type == "day"
        index_month = labels.index(debt[0].at_beginning_of_week.strftime("%U").to_i+1) if label_type == "week"
        tax_datas[index_month] += debt[1].to_i.abs if index_month.present?
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

  private
    def param_page
      params[:page]
    end
end
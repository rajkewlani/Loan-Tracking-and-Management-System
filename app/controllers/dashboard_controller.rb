class DashboardController < ApplicationController
  require 'rubygems'
  require 'google_chart'
  before_filter :login_required

  def index
    initialize_chart
  end

  def top_three_users(date)
    if Loan.count == 0
      return { :underwriter_record_desc => nil, :collector_record_desc => nil, :garnisher_record_desc => nil }
    end
    @days_period = []
    @days_period[0] = date[:current_date]
    
    @days_period[1] = date[:one_day_before]
    @days_period[2] = date[:two_day_before]
    @days_period[3] = date[:three_day_before]
    @days_period[4] = date[:four_day_before]
    @days_period[5] = date[:five_day_before]
    @days_period[6] = date[:six_day_before]
    @days_period[7] = date[:seven_day_before]
    @days_period[8] = date[:eight_day_before]
    @days_period[9] = date[:nine_day_before]
    @days_period[10] = date[:ten_day_before]
    @days_period[11] = date[:elevan_day_before]

   

    @loan_data = []
    @new_loan_data = []
    @reloan_data = []
    @loan_count = []
    @underwriter_name = []
    @underwriter_full_name = []
    @underwriter_record = []
    @collector_record = []
    @collector_name = []
    @garnishment_record = []
    @collectors_loan_count = []
    @collectors_full_name = []
    @garnisher_name = []
    @garnisher_loan_count = []
    @garnisher_full_name = []
    @garnisher_record = []
    @collectors_loan_count_desc = []
    @collector_name_desc = []
    @collector_record_desc = []
    @underwriter_record_desc = []
    @garnisher_record_desc = []
    @underwriter_loan_count = Array.new

    @underwriters = Loan.find(:all, :conditions => {:funded_on => @days_period[11] .. @days_period[0]}, :group => 'underwriter_id')
    @collectors = Loan.find(:all, :conditions => ["collections_agent_id is not null && funded_on between ? and ?",@days_period[11],@days_period[0] ], :group => 'collections_agent_id')
    @garnishers = Loan.find(:all, :conditions => ["garnishments_agent_id is not null && funded_on between ? and ?",@days_period[11],@days_period[0] ], :group => 'garnishments_agent_id')

   
    @under = @underwriters.sort_by {|a,b|b}
    @collect = @collectors.sort_by {|a,b|b}
    @garnish = @garnishers.sort_by {|a,b|b}

    @under_count = @underwriters.count - 1
    @collect_count = @collectors.count - 1
    @garnish_count = @garnishers.count - 1

    @under_start_count =  @under_count - 2
    for i in (@under_start_count..@under_count)
        if i > 0
        logger.info "i: #{i}"
        @underwriter_name << User.find_by_id(@under[i][0])
        @loan_count << @under[i][1]
        end
    end

    @collect_start_count =  @collect_count - 2
    for i in (@collect_start_count..@collect_count)
      if i > 0
      @collector_name << User.find_by_id(@collect[i][0])
      @collectors_loan_count << @collect[i][1]
      end
    end



    @garnisher_start_count =  @garnish_count - 2
    for i in (@garnisher_start_count..@garnish_count)
      if i > 0
      @garnisher_name << User.find_by_id(@garnish[i][0])
      @garnisher_loan_count << @garnish[i][1]
      end
    end

    if @underwriter_name.size >= 3
      for i in (0..2)
        @underwriter_full_name << @underwriter_name[i].first_name + " " + @underwriter_name[i].last_name
        @underwriter_record <<  {:underwriter_full_name => @underwriter_full_name[i],:loan_count => @loan_count[i].to_s } #@underwriter_full_name[i] + " " + @loan_count[i].to_s

        @collectors_full_name << @collector_name[i].first_name + " " + @collector_name[i].last_name
        @collector_record <<  {:collector_full_name => @collectors_full_name[i],:collections_loan_count => @collectors_loan_count[i].to_s } #@underwriter_full_name[i] + " " + @loan_count[i].to_s

        @garnisher_full_name << @garnisher_name[i].first_name + " " + @garnisher_name[i].last_name
        @garnisher_record <<  {:garnisher_full_name => @garnisher_full_name[i],:garnisher_loan_count => @garnisher_loan_count[i].to_s } #@underwriter_full_name[i] + " " + @loan_count[i].to_s
      end
    end
    @underwriter_record_desc = @underwriter_record.reverse
    @collector_record_desc = @collector_record.reverse
    @garnisher_record_desc = @garnisher_record.reverse

    {:underwriter_record_desc => @underwriter_record_desc, :collector_record_desc => @collector_record_desc, :garnisher_record_desc =>@garnisher_record_desc}
    
  end

  def initialize_chart
    if Loan.count == 0
      gchart(0,0,0,0,0,0,0,0,0,0,0)
      return
    end
    @loan_data = []
    @new_loan_data = []
    @reloan_data = []
    @loan_count = []
    @underwriter_name = []
    @underwriter_full_name = []
    @underwriter_record = []
    @collector_record = []
    @collector_name = []
    @garnishment_record = []
    @collectors_loan_count = []
    @collectors_full_name = []
    @garnisher_name = []
    @garnisher_loan_count = []
    @garnisher_full_name = []
    @garnisher_record = []
    @collectors_loan_count_desc = []
    @collector_name_desc = []
    @collector_record_desc = []
    @underwriter_record_desc = []
    @garnisher_record_desc = []
    @underwriter_loan_count = Array.new

    @date = []
    @topusers = []
    @date = get_weekdays
    @topusers = top_three_users(@date)


    #    @days_period[0] = @current_period
    #    @days_period[1] = @one_period_before
    #    @days_period[2] = @two_period_before
    #    @days_period[3] = @three_period_before
    #    @days_period[4] = @four_period_before
    #    @days_period[5] = @five_period_before
    #    @days_period[6] = @six_period_before
    #    @days_period[7] = @seven_period_before
    #    @days_period[8] = @eight_period_before
    #    @days_period[9] = @nine_period_before
    #    @days_period[10] = @ten_period_before
    #    @days_period[11] = @elevan_period_before

    @approved_new_loan_amount = 0
    @reloan_amount = 0
    @total_approved_loan_amount = 0
    @new_loan_fle = 0.0
    @reloan_amount = 0.0
    @total_amount = 0.0
    @fle_data = []
    for i in (0..11)
      @new_loans = Loan.count(:all,:conditions=>["reloan=? && funded_on=?",false,@days_period[i]])
      @reloan = Loan.count(:all,:conditions=>["reloan=? && funded_on=?",true,@days_period[i]])

      
      @fle_data = all_fle_data(@days_period[i])


      @total_loan = @new_loans + @reloan
      @loan_data[i] = @total_loan
      @new_loan_data[i] = @new_loans
      @reloan_data[i] = @reloan
    end


    @total_amount  = (@fle_data[:reloan_amount] + @fle_data[:approved_new_loan_amount]) / 300.00
    @new_loan_fle = @fle_data[:approved_new_loan_amount].to_f / 300.00
    @reloan_fle = @fle_data[:reloan_amount].to_f / 300.00


    @new_loan_fle = @approved_new_loan_amount.to_f / 300.00
    @reloan_fle = @reloan_amount.to_f / 300.00
    @total_amount = @new_loan_fle + @reloan_fle

    @loan_max = @loan_data.max
    @loan_min = @loan_data.min
    @new_loan_max = @new_loan_data.max
    @new_loan_min = @new_loan_data.min
    @reloan_max = @reloan_data.max
    @reloan_min = @reloan_data.min
    @loan_sum = @loan_data.sum
    @new_loan_sum = @new_loan_data.sum
    @reloan_sum = @reloan_data.sum
    @period = 12
    @duration = 'days'
    gchart(@period,@duration,@loan_data,@loan_max,@loan_min,@new_loan_data,@new_loan_max,@new_loan_min,@reloan_data,@reloan_max,@reloan_min)
  end

  def all_fle_data(days_period)
    @new_loans_approved = Loan.find(:all,:conditions=>["reloan=? && funded_on=?",false,days_period],:select=>"approved_loan_amount")
    @reloan_approved = Loan.find(:all,:conditions=>["reloan=? && funded_on=?",true,days_period])

    @new_loans_approved.each do |new_loan|
      if not new_loan.approved_loan_amount.nil?
        @approved_new_loan_amount = @approved_new_loan_amount + new_loan.approved_loan_amount
      end
    end

    @reloan_approved.each do |reloan|
      if not reloan.approved_loan_amount.nil?
        @reloan_amount = @reloan_amount + reloan.approved_loan_amount
      end
    end
    {:approved_new_loan_amount => @approved_new_loan_amount.to_f, :reloan_amount => @reloan_amount}
  end

  def get_weekdays

    @current_date = Date.today.to_date
    if @current_date.strftime('%a') == 'Mon'
      @one_day_before = @current_date - 3
      @two_day_before = @one_day_before - 1
      @three_day_before = @two_day_before - 1
      @four_day_before = @three_day_before - 1
      @five_day_before = @four_day_before - 1
      @six_day_before = @five_day_before - 3
      @seven_day_before = @six_day_before - 1
      @eight_day_before = @seven_day_before - 1
      @nine_day_before = @eight_day_before - 1
      @ten_day_before = @nine_day_before - 1
      @elevan_day_before = @ten_day_before - 3
    elsif @current_date.strftime('%a') == 'Tue'
      @one_day_before = @current_date - 1
      @two_day_before = @one_day_before - 3
      @three_day_before = @two_day_before - 1
      @four_day_before = @three_day_before - 1
      @five_day_before = @four_day_before - 1
      @six_day_before = @five_day_before - 1
      @seven_day_before = @six_day_before - 3
      @eight_day_before = @seven_day_before - 1
      @nine_day_before = @eight_day_before - 1
      @ten_day_before = @nine_day_before - 1
      @elevan_day_before = @ten_day_before - 1
    elsif @current_date.strftime('%a') == 'Wed'
      @one_day_before = @current_date - 1
      @two_day_before = @one_day_before - 1
      @three_day_before = @two_day_before - 3
      @four_day_before = @three_day_before - 1
      @five_day_before = @four_day_before - 1
      @six_day_before = @five_day_before - 1
      @seven_day_before = @six_day_before - 1
      @eight_day_before = @seven_day_before - 3
      @nine_day_before = @eight_day_before - 1
      @ten_day_before = @nine_day_before - 1
      @elevan_day_before = @ten_day_before - 1
    elsif @current_date.strftime('%a') == 'Thu'
      @one_day_before = @current_date - 1
      @two_day_before = @one_day_before - 1
      @three_day_before = @two_day_before - 1
      @four_day_before = @three_day_before - 3
      @five_day_before = @four_day_before - 1
      @six_day_before = @five_day_before - 1
      @seven_day_before = @six_day_before - 1
      @eight_day_before = @seven_day_before - 1
      @nine_day_before = @eight_day_before - 3
      @ten_day_before = @nine_day_before - 1
      @elevan_day_before = @ten_day_before - 1
    elsif @current_date.strftime('%a') == 'Fri'
      @one_day_before = @current_date - 1
      @two_day_before = @one_day_before - 1
      @three_day_before = @two_day_before - 1
      @four_day_before = @three_day_before - 1
      @five_day_before = @four_day_before - 3
      @six_day_before = @five_day_before - 1
      @seven_day_before = @six_day_before - 1
      @eight_day_before = @seven_day_before - 1
      @nine_day_before = @eight_day_before - 1
      @ten_day_before = @nine_day_before - 3
      @elevan_day_before = @ten_day_before - 1
    end
    {:current_date => @current_date, :one_day_before => @one_day_before, :two_day_before => @two_day_before, :three_day_before => @three_day_before, :four_day_before => @four_day_before, :five_day_before => @five_day_before, :six_day_before => @six_day_before, :seven_day_before => @seven_day_before, :eight_day_before => @eight_day_before, :nine_day_before => @nine_day_before, :ten_day_before => @ten_day_before, :elevan_day_before => @elevan_day_before}
  end

  def gchart(period,duration,loans,loans_max,loans_min,new_loans,new_loans_max,new_loans_min,reloans,reloans_max,reloans_min)
    if duration == 'single_day'
      @lable = "on " + period.to_s
    else
      @lable = "last " + period.to_s + " " + duration.to_s
    end
    GoogleChart::BarChart.new("200x150", "Loans", :vertical, false) do |bc|
      bc.data "First",loans, '6a99c5'
      bc.axis :x,:labels =>['','','','',@lable] #trend_period, :font_size => 10
      bc.axis :y,:range=>[loans_min,loans_max], :font_size => 10
      bc.show_legend = false
      bc.fill :background, :solid, :color => 'f0f0f0'
      bc.width_spacing_options :bar_width => 7, :bar_spacing => 4
      bc.data_encoding = :text
      @to_chart_url = bc.to_url
    end
    GoogleChart::BarChart.new("200x150", "New Loans", :vertical, false) do |bc1|
      bc1.data "New Loans",new_loans, '549b00'
      bc1.axis :x,:labels =>['','','','',@lable] #trend_period, :font_size => 10
      bc1.axis :y,:range=>[new_loans_min,new_loans_max], :font_size => 10
      bc1.show_legend = false
      bc1.fill :background, :solid, :color => 'f0f0f0'
      bc1.width_spacing_options :bar_width => 7, :bar_spacing => 4
      bc1.data_encoding = :text
      @to_chart_url1 = bc1.to_url
    end
    GoogleChart::BarChart.new("200x150", "Reloans", :vertical, false) do |bc2|
      bc2.data "Reloans",reloans, 'f3b81e'
      bc2.axis :x,:labels => ['','','','',@lable]#trend_period, :font_size => 10
      bc2.axis :y,:range=>[reloans_min,reloans_max], :font_size => 10
      bc2.show_legend = false
      bc2.fill :background, :solid, :color => 'f0f0f0'
      bc2.width_spacing_options :bar_width => 7, :bar_spacing => 4
      bc2.data_encoding = :text
      @to_chart_url2 = bc2.to_url
    end
  end

  def chart_asper_selectdate

    @date = []
    @topusers = []
    @date = get_weekdays
    @topusers = top_three_users(@date)

    date_string = params[:selectdate]
    if params[:portfolio_id]
      @portfolio_id = params[:portfolio_id]
    else
      @portfolio_id = 0
    end
    if date_string.include? "-"
      date_range = date_string.split("-")
      @start_date  = date_range[0].to_date
      @end_date    = date_range[1].to_date
      @days_between_dates = (@end_date - @start_date).to_i + 1

      @week = (@days_between_dates/7) + 1
      @month = (@days_between_dates/30) + 1
      @year = (@days_between_dates/365) + 1
    else
      @days_between_dates = 0
    end

    if (@days_between_dates == 0)
      chart_single_day(params[:selectdate],@portfolio_id)
    elsif (@days_between_dates < 12)
      return chart_period('days',@days_between_dates,@start_date,@portfolio_id)
    elsif (@week < 12)
      return chart_period('weeks',@week,@start_date,@portfolio_id)
    elsif (@month < 12)
      return chart_period('months',@month,@start_date,@portfolio_id)
    else
      return chart_period('years',@year,@start_date,@portfolio_id)
    end
  end

  def chart_single_day(single_date,portfolio_id)

    @fle_data = all_fle_data(single_date)

    if not @fle_data[:approved_new_loan_amount].nil? || @fle_data[:approved_new_loan_amount] != 0.0
      @new_loan_fle = @fle_data[:approved_new_loan_amount].to_f / 300.00
    else
      @new_loan_fle = 0.0
    end
    if not @fle_data[:reloan_amount].nil? || @fle_data[:reloan_amount] != 0.0
      @reloan_fle = @fle_data[:reloan_amount].to_f / 300.00
    else
      @reloan_fle = 0.0
    end
    @total_amount  = @new_loan_fle + @reloan_fle

    if portfolio_id == 0
      @new_loans = Loan.count(:all,:conditions=>["reloan=? && funded_on=?",false,single_date.to_date])
      @reloan = Loan.count(:all,:conditions=>["reloan=? && funded_on=?",true,single_date.to_date])
    else
      @new_loans = Loan.count(:all,:conditions=>["reloan=? && funded_on=? && portfolio_id=?",false,single_date.to_date,portfolio_id])
      @reloan = Loan.count(:all,:conditions=>["reloan=? && funded_on=? && portfolio_id=?",true,single_date.to_date,portfolio_id])
    end

    @total_loan = @new_loans + @reloan
    @loan_data = @total_loan
    @new_loan_data = @new_loans
    @reloan_data = @reloan
    @period = single_date.to_date
    @duration = 'single_day'
    @loan_max = @loan_data
    @loan_min = 0
    @new_loan_max = @new_loan_data
    @new_loan_min = 0
    @reloan_max = @reloan_data
    @reloan_min = 0
    @loan_sum = @loan_data
    @new_loan_sum = @new_loan_data
    @reloan_sum = @reloan_data

    gchart(@period,@duration,@loan_data,@loan_max,@loan_min,@new_loan_data,@new_loan_max,@new_loan_min,@reloan_data,@reloan_max,@reloan_min)
  end

  def chart_period(duration,period,start_date,portfolio_id)
    @period = period - 1
    @duration = duration
    @portfolio_id = portfolio_id
    @period_dates = []
    if duration == 'days'
      period_first = start_date
      for i in (0..@period)
        if not (period_first.strftime("%w") == "0" || period_first.strftime("%w") == "6")
          @period_dates[i] = period_first
        end
        period_first = period_first + 1
      end
    elsif duration == 'weeks'
      period_first = start_date.beginning_of_week
      for i in (0..@period)
        @period_dates[i] = period_first
        period_first = period_first + 7
      end
    elsif duration == 'months'
      period_first = start_date.beginning_of_month
      for i in (0..@period)
        @period_dates[i] = period_first
        period_first = period_first >> 1
      end
    else
      period_first = start_date.year
      for i in (0..@period)
        @period_dates[i] = period_first
        period_first = period_first + 1
      end
    end

    return chart_data(@period,@period_dates,@duration,@portfolio_id)
  end

  def chart_data(period,period_dates,duration,portfolio_id)

    @approved_new_loan_amount = 0
    @reloan_amount = 0
    @total_approved_loan_amount = 0
    @new_loan_fle = 0.0
    @reloan_amount = 0.0
    @total_amount = 0.0
    @fle_data = []

    @loan_data = []
    @new_loan_data = []
    @reloan_data = []
    for i in (0..period)
      if duration == 'days'
        @fle_data = all_fle_data(period_dates)

        if portfolio_id == 0
          @new_loans = Loan.count(:all,:conditions=> {:funded_on => period_dates[i], :reloan => false})
          @reloan = Loan.count(:all,:conditions=> {:funded_on => period_dates[i], :reloan => true})
        else
          @new_loans = Loan.count(:all,:conditions=> {:funded_on => period_dates[i], :reloan => false, :portfolio_id => portfolio_id})
          @reloan = Loan.count(:all,:conditions=> {:funded_on => period_dates[i], :reloan => true, :portfolio_id => portfolio_id})
        end
      elsif duration == 'weeks'
        
        if portfolio_id == 0
          @new_loans = Loan.count(:all,:conditions=> {:funded_on => period_dates[i].beginning_of_week .. period_dates[i].end_of_week, :reloan => false})
          @reloan = Loan.count(:all,:conditions=> {:funded_on => period_dates[i].beginning_of_week .. period_dates[i].end_of_week, :reloan => true})

          @new_loans_approved = Loan.find(:all,:conditions=>{:funded_on => period_dates[i].beginning_of_week .. period_dates[i].end_of_week, :reloan => false})
          @reloan_approved = Loan.find(:all,:conditions=>{:funded_on => period_dates[i].beginning_of_week .. period_dates[i].end_of_week, :reloan => true})
        else
          @new_loans = Loan.count(:all,:conditions=> {:funded_on => period_dates[i].beginning_of_week .. period_dates[i].end_of_week, :reloan => false, :portfolio_id => portfolio_id})
          @reloan = Loan.count(:all,:conditions=> {:funded_on => period_dates[i].beginning_of_week .. period_dates[i].end_of_week, :reloan => true, :portfolio_id => portfolio_id})

          @new_loans_approved = Loan.find(:all,:conditions=> {:funded_on => period_dates[i].beginning_of_week .. period_dates[i].end_of_week, :reloan => false, :portfolio_id => portfolio_id})
          @reloan_approved = Loan.find(:all,:conditions=> {:funded_on => period_dates[i].beginning_of_week .. period_dates[i].end_of_week, :reloan => true, :portfolio_id => portfolio_id})
        end
      elsif duration == 'months'
        if portfolio_id == 0
          @new_loans = Loan.count(:all,:conditions=> {:funded_on => period_dates[i].beginning_of_month .. period_dates[i].end_of_month, :reloan => false})
          @reloan = Loan.count(:all,:conditions=> {:funded_on => period_dates[i].beginning_of_month .. period_dates[i].end_of_month, :reloan => true})

          @new_loans_approved = Loan.find(:all,:conditions=> {:funded_on => period_dates[i].beginning_of_month .. period_dates[i].end_of_month, :reloan => false})
          @reloan_approved = Loan.find(:all,:conditions=> {:funded_on => period_dates[i].beginning_of_month .. period_dates[i].end_of_month, :reloan => true})
        else
          @new_loans = Loan.count(:all,:conditions=> {:funded_on => period_dates[i].beginning_of_month .. period_dates[i].end_of_month, :reloan => false, :portfolio_id => portfolio_id})
          @reloan = Loan.count(:all,:conditions=> {:funded_on => period_dates[i].beginning_of_month .. period_dates[i].end_of_month, :reloan => true, :portfolio_id => portfolio_id})

          @new_loans_approved = Loan.find(:all,:conditions=> {:funded_on => period_dates[i].beginning_of_month .. period_dates[i].end_of_month, :reloan => false, :portfolio_id => portfolio_id})
          @reloan_approved = Loan.find(:all,:conditions=> {:funded_on => period_dates[i].beginning_of_month .. period_dates[i].end_of_month, :reloan => true, :portfolio_id => portfolio_id})
        end
      elsif duration == 'years'

        if portfolio_id == 0
          @new_loans = Loan.count(:all,:conditions=> [ "YEAR(funded_on) =? && reloan =? && portfolio_id =?" ,period_dates[i],false])
          @reloan = Loan.count(:all,:conditions=> [ "YEAR(funded_on) =? && reloan =? && portfolio_id =?" ,period_dates[i],true])

          @new_loans_approved = Loan.find(:all,:conditions=> [ "YEAR(funded_on) =? && reloan =? && portfolio_id =?" ,period_dates[i],false])
          @reloan_approved = Loan.find(:all,:conditions=> [ "YEAR(funded_on) =? && reloan =? && portfolio_id =?" ,period_dates[i],true])
        else
          @new_loans = Loan.count(:all,:conditions=> [ "YEAR(funded_on) =? && reloan =? && portfolio_id =?" ,period_dates[i],false,portfolio_id])
          @reloan = Loan.count(:all,:conditions=> [ "YEAR(funded_on) =? && reloan =? && portfolio_id =?" ,period_dates[i],true,portfolio_id])

          @new_loans_approved = Loan.find(:all,:conditions=> [ "YEAR(funded_on) =? && reloan =? && portfolio_id =?" ,period_dates[i],false,portfolio_id])
          @reloan_approved = Loan.find(:all,:conditions=> [ "YEAR(funded_on) =? && reloan =? && portfolio_id =?" ,period_dates[i],true,portfolio_id])
        end
      end

      @new_loans_approved.each do |new_loan|
        if not new_loan.approved_loan_amount.nil?
          @approved_new_loan_amount = @approved_new_loan_amount + new_loan.approved_loan_amount
        end
      end


      @reloan_approved.each do |reloan|
        if not reloan.approved_loan_amount.nil?
          @reloan_amount = @reloan_amount + reloan.approved_loan_amount
        end
      end

      

      if  @approved_new_loan_amount != 0.0
        @new_loan_fle = @approved_new_loan_amount.to_f / 300.00
      else
        @new_loan_fle = 0.0
      end
      if @reloan_amount != 0.0
        @reloan_fle = @reloan_amount.to_f / 300.00
      else
        @reloan_fle = 0.0
      end
      @total_amount  = @new_loan_fle + @reloan_fle
      
      @total_loan = @new_loans + @reloan
      @loan_data[i] = @total_loan
      @new_loan_data[i] = @new_loans
      @reloan_data[i] = @reloan
    end

    #{:approved_new_loan_amount => @new_loan_fle.to_f, :reloan_amount => @reloan_fle}

    @period = period + 1
    @duration = duration
    @loan_max = @loan_data.max
    @loan_min = @loan_data.min
    @new_loan_max = @new_loan_data.max
    @new_loan_min = @new_loan_data.min
    @reloan_max = @reloan_data.max
    @reloan_min = @reloan_data.min
    @loan_sum = @loan_data.sum
    @new_loan_sum = @new_loan_data.sum
    @reloan_sum = @reloan_data.sum

    gchart(@period,@duration,@loan_data,@loan_max,@loan_min,@new_loan_data,@new_loan_max,@new_loan_min,@reloan_data,@reloan_max,@reloan_min)
  end
end

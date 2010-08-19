# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'fastercsv'
require 'spreadsheet'
require "pdf/writer"
require "pdf/simpletable"
#require 'spreadsheet/excel'
include Spreadsheet
class ReportsController < ApplicationController
  
  def marketing
    @market = "This is Marketing Report" #this is just a notification. you can remove it.

  end

  def portfolio
    
    if current_user.role == 'underwriter'
      @portfolio = Loan.find(:first, :conditions => ["underwriter_id=?", current_user.id], :select => "DISTINCT portfolio_id")
      if !@portfolio.nil?
        @portfolio_all = Portfolio.find(:all, :include => [:loans], :conditions => ['loans.underwriter_id=?', current_user.id])
      end
    elsif current_user.role == 'administrator'
      @portfolio = Loan.first
      if !@portfolio.nil?
        @portfolio_all = Portfolio.all
      end
    end
    # calculations for today section
    if(!@portfolio.nil?)
      @new_loan_today = Loan.count(:all,:conditions=>["DATE(approved_at)=?",Date.today.to_date])
      @re_loan_today = Loan.count(:all,:conditions=>["DATE(approved_at)=?",Date.today.to_date])
      @total_today = @new_loan_today + @re_loan_today

      if @total_today == 0
        @perc_re_loan_today = 0.0
      else
        @perc_re_loan_today = ((@re_loan_today)/(@total_today)*(100))
      end
      @total_LTD_today = Loan.count(:all, :conditions => ["portfolio_id=? && DATE(approved_at)=?",@portfolio[:portfolio_id],Date.today.to_date])
      @loan_out_today = Loan.count(:all, :conditions => ["portfolio_id=? && DATE(approved_at)=? && funded_on !=? && aasm_state not in (?)",@portfolio[:portfolio_id],Date.today.to_date,nil,["paid_in_full","written_off"]])

      session[:portfolio_id] = @portfolio[:portfolio_id]
      session[:trend] = "1"

      

      #calculations for daily(default) trend
      @daily_data = Array.new
      @daily_data = get_trend
      @trend_avg = get_trend_avg(@daily_data)
    end
  end

  def export_to_csv
    @perc_re_loan_today = 0.0

    @portfolio_id = session[:portfolio_id]

    @new_loan_today = Loan.count(:all,:conditions=>["DATE(approved_at)=?",Date.today.to_date])
    @re_loan_today = Loan.count(:all,:conditions=>["DATE(approved_at)=?",Date.today.to_date])
    @total_today = @new_loan_today + @re_loan_today

    if @total_today == 0
      @perc_re_loan_today = 0.0
    else
      @perc_re_loan_today = ((@re_loan_today)/(@total_today)*(100))
    end
    @total_LTD_today = Loan.count(:all, :conditions => ["portfolio_id=? && DATE(approved_at)=?",@portfolio_id,Date.today.to_date])
    @loan_out_today = Loan.count(:all, :conditions => ["portfolio_id=? && DATE(approved_at)=? && funded_on !=? && aasm_state not in (?)",@portfolio_id,Date.today.to_date,nil,["paid_in_full","written_off"]])
    csv_string = FasterCSV.generate do |csv|
      csv << ["","","","Today","","",""]
      csv << ["Portfolio","New Loans","Reloans","RL %","Total","Total LTD","Loans Out"]
      csv << ["All",@new_loan_today,@re_loan_today,@perc_re_loan_today.to_s+"%",@total_today,@total_LTD_today,@loan_out_today]
      csv << ["","","","","","",""]
      csv << ["","","","","","",""]
      if session[:trend] == "1"
        @daily_data = Array.new
        @daily_data = get_trend
        @trend_avg = get_trend_avg(@daily_data)
        csv << ["","","","Trend Average","","",""]
        csv << ["Portfolio","New Loans","Reloans","RL %","Total","Total LTD","Loans Out"]
        csv << ["All",@trend_avg[:new_loan_avg],@trend_avg[:reloan_avg],@trend_avg[:reloan_perc_avg].to_s+"%",@trend_avg[:total_loan_avg],"N/A",@trend_avg[:loans_out_avg]]
        csv << ["","","","","","",""]
        csv << ["","","","","","",""]
        csv << ["","","","Trend for Last 6 Days","","",""]
        csv << ["Days","New Loans","Reloans","RL %","Total","Total LTD","Loans Out"]
        @daily_data.each do |daily_data|
          csv << [
            daily_data[:snapshot_on].strftime('%A'),
            daily_data[:new_loans_today],
            daily_data[:reloans_today],
            daily_data[:reloan_percentage].to_s+"%",
            daily_data[:total_loans_today],
            daily_data[:total_loans_to_date],
            daily_data[:loans_out_today]
          ]
        end
      elsif session[:trend] == "2"
        @sum_weekly_data = Array.new
        @sum_weekly_data = get_trend
        @trend_avg = get_trend_avg(@sum_weekly_data)
        csv << ["","","","Trend Average","","",""]
        csv << ["Portfolio","New Loans","Reloans","RL %","Total","Total LTD","Loans Out"]
        csv << ["All",@trend_avg[:new_loan_avg],@trend_avg[:reloan_avg],@trend_avg[:reloan_perc_avg].to_s+"%",@trend_avg[:total_loan_avg],"N/A",@trend_avg[:loans_out_avg]]
        csv << ["","","","","","",""]
        csv << ["","","","","","",""]
        csv << ["","","","Trend for Last 6 Weeks","","",""]
        csv << ["Weeks","New Loans","Reloans","RL %","Total","Total LTD","Loans Out"]
        @sum_weekly_data.each do |weekly_data|
          csv << [
            weekly_data[:week_number],
            weekly_data[:new_loans_today],
            weekly_data[:reloans_today],
            weekly_data[:reloan_percentage].to_s+"%",
            weekly_data[:total_loans_today],
            weekly_data[:total_loans_to_date],
            weekly_data[:loans_out_today]
          ]
        end
      elsif session[:trend] == "3"
        @sum_monthly_data = Array.new
        @sum_monthly_data = get_trend
        @trend_avg = get_trend_avg(@sum_monthly_data)
        csv << ["","","","Trend Average","","",""]
        csv << ["Portfolio","New Loans","Reloans","RL %","Total","Total LTD","Loans Out"]
        csv << ["All",@trend_avg[:new_loan_avg],@trend_avg[:reloan_avg],@trend_avg[:reloan_perc_avg].to_s+"%",@trend_avg[:total_loan_avg],"N/A",@trend_avg[:loans_out_avg]]
        csv << ["","","","","","",""]
        csv << ["","","","","","",""]
        csv << ["","","","Trend for Last 6 Months","","",""]
        csv << ["Months","New Loans","Reloans","RL %","Total","Total LTD","Loans Out"]
        @sum_monthly_data.each do |monthly_data|
          csv << [
            monthly_data[:month_name],
            monthly_data[:new_loans_today],
            monthly_data[:reloans_today],
            monthly_data[:reloan_percentage],
            monthly_data[:total_loans_today],
            monthly_data[:total_loans_to_date],
            monthly_data[:loans_out_today]
          ]
        end
      elsif session[:trend] == "4"
        @sum_yearly_data = Array.new
        @sum_yearly_data = get_trend
        @trend_avg = get_trend_avg(@sum_yearly_data)
        csv << ["","","","Trend Average","","",""]
        csv << ["Portfolio","New Loans","Reloans","RL %","Total","Total LTD","Loans Out"]
        csv << ["All",@trend_avg[:new_loan_avg],@trend_avg[:reloan_avg],@trend_avg[:reloan_perc_avg],@trend_avg[:total_loan_avg],"N/A",@trend_avg[:loans_out_avg]]
        csv << ["","","","","","",""]
        csv << ["","","","","","",""]
        csv << ["","","","Trend for Last 6 Years","","",""]
        csv << ["Years","New Loans","Reloans","RL %","Total","Total LTD","Loans Out"]
        @sum_yearly_data.each do |yearly_data|
          csv << [
            yearly_data[:year_number],
            yearly_data[:new_loans_today],
            yearly_data[:reloans_today],
            yearly_data[:reloan_percentage],
            yearly_data[:total_loans_today],
            yearly_data[:total_loans_to_date],
            yearly_data[:loans_out_today]
          ]
        end
      end
    end
    send_data csv_string,:type => "text/csv", :filename=>"export_#{current_user.username}.csv", :disposition => 'attachment'
  end

  def export_performance_data_to_pdf

    performance_data_pdf = PDF::Writer.new(:paper =>"A4")
    performance_data_pdf.move_pointer(80)

    performance_data_pdf.select_font "Times-Roman"
    performance_data_pdf.text  "Export Performance Data",:font_size => 30, :justification => :center

    performance_data_pdf.move_pointer(50)

    department_table = PDF::SimpleTable.new
    department_table.title_gap = 15
    department_table.title = "Department"
    department_table.column_order.push(*%w(Name Apps. Yes	Hour Day Conv. No	1stD %))

    department_table.show_lines    = :all
    department_table.position      = :center

    @get_team_performance_data = Array.new
      if session[:date_select] == ""
        @get_team_performance_data = performance_member_data_calculation("")
      else
        @get_team_performance_data = performance_member_data_calculation(session[:date_select])
      end

    @get_all_deparment_performance_data = department_performance_data(@get_team_performance_data)

    data = [
      {
        "Name"=> "All",
        "Apps."=> @get_all_deparment_performance_data[:department_wise_loan],
        "Yes"=>@get_all_deparment_performance_data[:department_wise_loan_approved],
        "Hour"=>@get_all_deparment_performance_data[:department_wise_loan_approved_per_hour],
        "Day" =>@get_all_deparment_performance_data[:department_wise_loan_approved_per_day],
        "Conv." =>@get_all_deparment_performance_data[:department_wise_percentage].to_s + "%",
        "No" =>@get_all_deparment_performance_data[:deparment_wise_loan_rejecet],
        "1stD"=>@get_all_deparment_performance_data[:department_wise_loan_collections_on],
        "%"=>@get_all_deparment_performance_data[:department_wise_loan_funded_on]
      } # First row
    ]

    department_table.data.replace data
    department_table.render_on(performance_data_pdf)

    performance_data_pdf.move_pointer(30)

    myteam_table = PDF::SimpleTable.new
    myteam_table.title_gap = 15
    myteam_table.title = "My Team"
    myteam_table.column_order.push(*%w(Name Apps. Yes	Hour Day Conv. No	1stD %))
    data = Array.new

     @get_team_performance_data.each do |get_team_performance_data|
       data << {
         "Name"=>get_team_performance_data[:first_name],
         "Apps." => get_team_performance_data[:member_loan_count],
         "Yes" => get_team_performance_data[:loan_approved],
         "Hour" => get_team_performance_data[:approved_loan_per_hour],
         "Day" => get_team_performance_data[:approved_loan_per_day],
         "Conv." =>get_team_performance_data[:percentage_of_loan_approved].to_s + "%",
         "No" => get_team_performance_data[:loan_rejected],
         "1stD" => get_team_performance_data[:loan_collections_on],
         "%" => get_team_performance_data[:percentage_funded_on]
       }
     end

     myteam_table.data.replace data
     myteam_table.render_on(performance_data_pdf)

    send_data(performance_data_pdf.render, :type => 'application/pdf', :filename => "export_performance_data.pdf", :disposition => 'attachment')
  end

  def export_to_pdf

    pdf = PDF::Writer.new(:paper =>"A4")
    pdf.move_pointer(80)

    pdf.select_font "Times-Roman"
    pdf.text  "Export Underwriter",:font_size => 30, :justification => :center

    pdf.move_pointer(50)

    today_table = PDF::SimpleTable.new
    today_table.title_gap = 15
    today_table.title = "Today"
    today_table.column_order.push(*%w(Portfolio NewLoans Reloans RL%  Total TotalLTD LoansOut))

    today_table.show_lines    = :all
    today_table.position      = :center

    @portfolio_id = session[:portfolio_id]
    @new_loan_today = Loan.count(:all,:conditions=>["DATE(approved_at)=?",Date.today.to_date])
    @re_loan_today = Loan.count(:all,:conditions=>["DATE(approved_at)=?",Date.today.to_date])
    @total_today = @new_loan_today + @re_loan_today

    if @total_today == 0
      @perc_re_loan_today = 0.0
    else
      @perc_re_loan_today = ((@re_loan_today)/(@total_today)*(100))
    end
    @total_LTD_today = Loan.count(:all, :conditions => ["portfolio_id=? && DATE(approved_at)=?",@portfolio_id,Date.today.to_date])
    @loan_out_today = Loan.count(:all, :conditions => ["portfolio_id=? && DATE(approved_at)=? && funded_on !=? && aasm_state not in (?)",@portfolio_id,Date.today.to_date,nil,["paid_in_full","written_off"]])

    data = [
      {"Portfolio"=> "All", "NewLoans"=> @new_loan_today,"Reloans"=>@re_loan_today, "RL%"=>@perc_re_loan_today,"Total" =>@total_today,"TotalLTD" =>@total_LTD_today,"LoansOut" => @loan_out_today } # First row
    ]

    today_table.data.replace data
    today_table.render_on(pdf)
    pdf.move_pointer(30)
    @sum_monthly_data = Array.new
    @sum_monthly_data = get_trend
    @trend_avg = get_trend_avg(@sum_monthly_data)

    if session[:trend] == "1"
      @daily_data = Array.new
      @daily_data = get_trend
      @trend_avg = get_trend_avg(@daily_data)

      daily_trend_average_table = PDF::SimpleTable.new
      daily_trend_average_table.title_gap = 15
      daily_trend_average_table.width = 100

      daily_trend_average_table.title = "Trend Average"
      daily_trend_average_table.column_order.push(*%w(Portfolio NewLoans Reloans RL%  Total TotalLTD LoansOut))

      data = [{
          "Portfolio"=> "All",
          "NewLoans"=> @trend_avg[:new_loan_avg],
          "Reloans"=>@trend_avg[:reloan_avg],
          "RL%"=>@trend_avg[:reloan_perc_avg],
          "Total" =>@trend_avg[:total_loan_avg],
          "TotalLTD" =>"N/A",
          "LoansOut" => @trend_avg[:loans_out_avg]
        }]
      daily_trend_average_table.data.replace data
      daily_trend_average_table.render_on(pdf)

      pdf.move_pointer(50)

      last_six_days_table = PDF::SimpleTable.new
      last_six_days_table.title_gap = 15

      last_six_days_table.title = "Trend for Last 6 Days"
      last_six_days_table.column_order.push(*%w(Days NewLoans Reloans RL%  Total TotalLTD LoansOut))
      data = Array.new
      @daily_data.each do |daily_data|
        data = [
          {
            "Days"=>daily_data[:snapshot_on].strftime('%A'),
            "NewLoans"=> daily_data[:new_loans_today],
            "Reloans"=>daily_data[:reloans_today],
            "RL%"=>daily_data[:reloan_percentage],
            "Total" =>daily_data[:total_loans_today],
            "TotalLTD" =>daily_data[:total_loans_to_date],
            "LoansOut" => daily_data[:loans_out_today]
            }
        ]
      end
      last_six_days_table.data.replace data
      last_six_days_table.render_on(pdf)
      pdf.move_pointer(50)
    elsif session[:trend] == "2"
      @sum_weekly_data = Array.new
      @sum_weekly_data = get_trend
      @trend_avg = get_trend_avg(@sum_weekly_data)

      week_trend_average_table = PDF::SimpleTable.new
      week_trend_average_table.title_gap = 15
      week_trend_average_table.title = "Trend Average"
      week_trend_average_table.column_order.push(*%w(Portfolio NewLoans Reloans RL%  Total TotalLTD LoansOut))

      data = [{
          "Portfolio"=> "All",
          "NewLoans"=> @trend_avg[:new_loan_avg],
          "Reloans"=>@trend_avg[:reloan_avg],
          "RL%"=>@trend_avg[:reloan_perc_avg],
          "Total" =>@trend_avg[:total_loan_avg],
          "TotalLTD" =>"N/A",
          "LoansOut" => @trend_avg[:loans_out_avg]
        }]
      week_trend_average_table.data.replace data
      week_trend_average_table.render_on(pdf)

      pdf.move_pointer(50)

      last_six_weeks_table = PDF::SimpleTable.new
      last_six_weeks_table.title_gap = 15
      last_six_weeks_table.title = "Trend for Last 6 Weeks"
      last_six_weeks_table.column_order.push(*%w(Weeks NewLoans Reloans RL%  Total TotalLTD LoansOut))
      data = Array.new
      @sum_weekly_data.each do |weekly_data|
        data << {
          "Weeks"=>weekly_data[:week_number],
          "NewLoans"=> weekly_data[:new_loans_today],
          "Reloans"=>weekly_data[:reloans_today],
          "RL%"=>weekly_data[:reloan_percentage],
          "Total" =>weekly_data[:total_loans_today],
          "TotalLTD" =>weekly_data[:total_loans_to_date],
          "LoansOut" => weekly_data[:loans_out_today]
        }
      end
      last_six_weeks_table.data.replace data
      last_six_weeks_table.render_on(pdf)

      pdf.move_pointer(50)

    elsif session[:trend] == "3"
      @sum_monthly_data = Array.new
      @sum_monthly_data = get_trend
      @trend_avg = get_trend_avg(@sum_monthly_data)

      month_trend_average_table = PDF::SimpleTable.new
      month_trend_average_table.title_gap = 15
      month_trend_average_table.title = "Trend Average"
      month_trend_average_table.column_order.push(*%w(Portfolio NewLoans Reloans RL%  Total TotalLTD LoansOut))

      data = [{
          "Portfolio"=> "All",
          "NewLoans"=> @trend_avg[:new_loan_avg],
          "Reloans"=>@trend_avg[:reloan_avg],
          "RL%"=>@trend_avg[:reloan_perc_avg],
          "Total" =>@trend_avg[:total_loan_avg],
          "TotalLTD" =>"N/A",
          "LoansOut" => @trend_avg[:loans_out_avg]
        }]
      month_trend_average_table.data.replace data
      month_trend_average_table.render_on(pdf)
      pdf.move_pointer(50)
      last_six_months_table = PDF::SimpleTable.new
      last_six_months_table.title_gap = 15
      last_six_months_table.title = "Trend for Last 6 Months"
      last_six_months_table.column_order.push(*%w(Months NewLoans Reloans RL%  Total TotalLTD LoansOut))
      data = Array.new
      @sum_monthly_data.each do |monthly_data|
        data << {
          "Months"=>monthly_data[:month_name],
          "NewLoans"=> monthly_data[:new_loans_today],
          "Reloans"=>monthly_data[:reloans_today],
          "RL%"=>monthly_data[:reloan_percentage],
          "Total" =>monthly_data[:total_loans_today],
          "TotalLTD" =>monthly_data[:total_loans_to_date],
          "LoansOut" => monthly_data[:loans_out_today]
        }
      end
      last_six_months_table.data.replace data
      last_six_months_table.render_on(pdf)
      pdf.move_pointer(50)
    elsif session[:trend] == "4"
      @sum_yearly_data = Array.new
      @sum_yearly_data = get_trend
      @trend_avg = get_trend_avg(@sum_yearly_data)

      year_trend_average_table = PDF::SimpleTable.new
      year_trend_average_table.title_gap = 15
      year_trend_average_table.title = "Trend Average"
      year_trend_average_table.column_order.push(*%w(Portfolio NewLoans Reloans RL%  Total TotalLTD LoansOut))

      data = [{
          "Portfolio"=> "All",
          "NewLoans"=> @trend_avg[:new_loan_avg],
          "Reloans"=>@trend_avg[:reloan_avg],
          "RL%"=>@trend_avg[:reloan_perc_avg],
          "Total" =>@trend_avg[:total_loan_avg],
          "TotalLTD" =>"N/A",
          "LoansOut" => @trend_avg[:loans_out_avg]
        }]

      year_trend_average_table.data.replace data
      year_trend_average_table.render_on(pdf)

      pdf.move_pointer(50)

      last_six_years_table = PDF::SimpleTable.new
      last_six_years_table.title_gap = 15
      last_six_years_table.title = "Trend for Last 6 Years"
      last_six_years_table.column_order.push(*%w(Years NewLoans Reloans RL%  Total TotalLTD LoansOut))
      data = Array.new
      @sum_yearly_data.each do |yearly_data|
        data << {
          "Years"=>yearly_data[:year_number],
          "NewLoans"=> yearly_data[:new_loans_today],
          "Reloans"=>yearly_data[:reloans_today],
          "RL%"=>yearly_data[:reloan_percentage],
          "Total" =>yearly_data[:total_loans_today],
          "TotalLTD" =>yearly_data[:total_loans_to_date],
          "LoansOut" => yearly_data[:loans_out_today]
        }
      end

      last_six_years_table.data.replace data
      last_six_years_table.render_on(pdf)
    end

    send_data(pdf.render, :type => 'application/pdf', :filename => "export_underwriter.pdf", :disposition => 'attachment')

  end

    def export_performance_data_to_excel

      performance_excel_content = StringIO.new
      performance_workbook = Excel.new(performance_excel_content)

      start_column, start_row = 0, 0
      performance_worksheet = performance_workbook.add_worksheet("Export_Underwriter")

      performance_worksheet.write(start_row,start_column+3,"Department")
      performance_worksheet.write(start_row+1,start_column,"Name")
      performance_worksheet.write(start_row+1,start_column+1,"Apps")
      performance_worksheet.write(start_row+1,start_column+2,"Yes")
      performance_worksheet.write(start_row+1,start_column+3,"Hour")
      performance_worksheet.write(start_row+1,start_column+4,"Day")
      performance_worksheet.write(start_row+1,start_column+5,"Conv.")
      performance_worksheet.write(start_row+1,start_column+6,"No")
      performance_worksheet.write(start_row+1,start_column+7,"1stD")
      performance_worksheet.write(start_row+1,start_column+8,"%")

      @get_team_performance_data = Array.new
      if session[:date_select] == ""
        @get_team_performance_data = performance_member_data_calculation("")
      else
        @get_team_performance_data = performance_member_data_calculation(session[:date_select])
      end

      @get_all_deparment_performance_data = department_performance_data(@get_team_performance_data)

      performance_worksheet.write(start_row+2,start_column,"All")
      performance_worksheet.write(start_row+2,start_column+1,@get_all_deparment_performance_data[:department_wise_loan])
      performance_worksheet.write(start_row+2,start_column+2,@get_all_deparment_performance_data[:department_wise_loan_approved])
      performance_worksheet.write(start_row+2,start_column+3,@get_all_deparment_performance_data[:department_wise_loan_approved_per_hour])
      performance_worksheet.write(start_row+2,start_column+4,@get_all_deparment_performance_data[:department_wise_loan_approved_per_day])
      performance_worksheet.write(start_row+2,start_column+5,@get_all_deparment_performance_data[:department_wise_percentage].to_s+"%")
      performance_worksheet.write(start_row+2,start_column+6,@get_all_deparment_performance_data[:deparment_wise_loan_rejecet])
      performance_worksheet.write(start_row+2,start_column+7,@get_all_deparment_performance_data[:department_wise_loan_collections_on])
      performance_worksheet.write(start_row+2,start_column+8,@get_all_deparment_performance_data[:department_wise_loan_funded_on].to_f)

      performance_worksheet.write(start_row+5,start_column+3,"My Team")
      performance_worksheet.write(start_row+6,start_column,"Name")
      performance_worksheet.write(start_row+6,start_column+1,"Apps")
      performance_worksheet.write(start_row+6,start_column+2,"Yes")
      performance_worksheet.write(start_row+6,start_column+3,"Hour")
      performance_worksheet.write(start_row+6,start_column+4,"Day")
      performance_worksheet.write(start_row+6,start_column+5,"Conv.")
      performance_worksheet.write(start_row+6,start_column+6,"No")
      performance_worksheet.write(start_row+6,start_column+7,"1stD")
      performance_worksheet.write(start_row+6,start_column+8,"%")

       position = 7

       @get_team_performance_data.each do |get_team_performance_data|
          performance_worksheet.write(start_row+position,start_column,get_team_performance_data[:first_name])
          performance_worksheet.write(start_row+position,start_column+1,get_team_performance_data[:member_loan_count])
          performance_worksheet.write(start_row+position,start_column+2,get_team_performance_data[:loan_approved])
          performance_worksheet.write(start_row+position,start_column+3,get_team_performance_data[:approved_loan_per_hour])
          performance_worksheet.write(start_row+position,start_column+4,get_team_performance_data[:approved_loan_per_day])
          performance_worksheet.write(start_row+position,start_column+5,get_team_performance_data[:percentage_of_loan_approved].to_s+"%")
          performance_worksheet.write(start_row+position,start_column+6,get_team_performance_data[:loan_rejected])
          performance_worksheet.write(start_row+position,start_column+7,get_team_performance_data[:loan_collections_on])
          performance_worksheet.write(start_row+position,start_column+8,get_team_performance_data[:percentage_funded_on].to_f)
          position+=1
        end

      @filename = "export_performance_data.xls"
      performance_workbook.close
      send_data(performance_excel_content.string, :type => 'application/vnd.ms-excel',
        :filename => @filename,
        :disposition => 'attachment')
    end

    def export_to_excel

      excel_content = StringIO.new
      workbook = Excel.new(excel_content)

      start_column, start_row = 0, 0
      worksheet = workbook.add_worksheet("Export_Underwriter")

      worksheet.write(start_row,start_column+3,"Today")
      worksheet.write(start_row+1,start_column,"Portfolio")
      worksheet.write(start_row+1,start_column+1,"New Loans")
      worksheet.write(start_row+1,start_column+2,"Reloans")
      worksheet.write(start_row+1,start_column+3,"RL %")
      worksheet.write(start_row+1,start_column+4,"Total")
      worksheet.write(start_row+1,start_column+5,"Total LTD")
      worksheet.write(start_row+1,start_column+6,"Loans Out")

      @portfolio_id = session[:portfolio_id]

      @new_loan_today = Loan.count(:all,:conditions=>["DATE(approved_at)=?",Date.today.to_date])
      @re_loan_today = Loan.count(:all,:conditions=>["DATE(approved_at)=?",Date.today.to_date])
      @total_today = @new_loan_today + @re_loan_today

      if @total_today == 0
        @perc_re_loan_today = 0.0
      else
        @perc_re_loan_today = ((@re_loan_today)/(@total_today)*(100))
      end
      @total_LTD_today = Loan.count(:all, :conditions => ["portfolio_id=? && DATE(approved_at)=?",@portfolio_id,Date.today.to_date])
      @loan_out_today = Loan.count(:all, :conditions => ["portfolio_id=? && DATE(approved_at)=? && funded_on !=? && aasm_state not in (?)",@portfolio_id,Date.today.to_date,nil,["paid_in_full","written_off"]])

      worksheet.write(start_row+2,start_column,"All")
      worksheet.write(start_row+2,start_column+1,@new_loan_today)
      worksheet.write(start_row+2,start_column+2,@re_loan_today)
      worksheet.write(start_row+2,start_column+3,@perc_re_loan_today)
      worksheet.write(start_row+2,start_column+4,@total_today)
      worksheet.write(start_row+2,start_column+5,@total_LTD_today)
      worksheet.write(start_row+2,start_column+6,@loan_out_today)

      @sum_monthly_data = Array.new
      @sum_monthly_data = get_trend
      @trend_avg = get_trend_avg(@sum_monthly_data)

      if session[:trend] == "1"
        @daily_data = Array.new
        @daily_data = get_trend
        @trend_avg = get_trend_avg(@daily_data)

        worksheet.write(start_row+5,start_column+3,"Trend Average")
        worksheet.write(start_row+6,start_column,"Portfolio")
        worksheet.write(start_row+6,start_column+1,"New Loans")
        worksheet.write(start_row+6,start_column+2,"Reloans")
        worksheet.write(start_row+6,start_column+3,"RL %")
        worksheet.write(start_row+6,start_column+4,"Total")
        worksheet.write(start_row+6,start_column+5,"Total LTD")
        worksheet.write(start_row+6,start_column+6,"Loans Out")

        worksheet.write(start_row+7,start_column,"All")
        worksheet.write(start_row+7,start_column+1,@trend_avg[:new_loan_avg])
        worksheet.write(start_row+7,start_column+2,@trend_avg[:reloan_avg])
        worksheet.write(start_row+7,start_column+3,@trend_avg[:reloan_perc_avg])
        worksheet.write(start_row+7,start_column+4,@trend_avg[:total_loan_avg])
        worksheet.write(start_row+7,start_column+5,"N/A")
        worksheet.write(start_row+7,start_column+6,@trend_avg[:loans_out_avg])

        worksheet.write(start_row+9,start_column+3,"Trend for Last 6 Days")
        worksheet.write(start_row+10,start_column,"Days")
        worksheet.write(start_row+10,start_column+1,"New Loans")
        worksheet.write(start_row+10,start_column+2,"Reloans")
        worksheet.write(start_row+10,start_column+3,"RL %")
        worksheet.write(start_row+10,start_column+4,"Total")
        worksheet.write(start_row+10,start_column+5,"Total LTD")
        worksheet.write(start_row+10,start_column+6,"Loans Out")
        position = 10
        @daily_data.each do |daily_data|
          worksheet.write(start_row+position,start_column,daily_data[:snapshot_on].strftime('%A'))
          worksheet.write(start_row+position,start_column+1,daily_data[:new_loans_today])
          worksheet.write(start_row+position,start_column+2,daily_data[:reloans_today])
          worksheet.write(start_row+position,start_column+3,daily_data[:reloan_percentage])
          worksheet.write(start_row+position,start_column+4,daily_data[:total_loans_today])
          worksheet.write(start_row+position,start_column+5,daily_data[:total_loans_to_date])
          worksheet.write(start_row+position,start_column+6,daily_data[:loans_out_today])
          position+=1
        end
      elsif session[:trend] == "2"
        @sum_weekly_data = Array.new
        @sum_weekly_data = get_trend
        @trend_avg = get_trend_avg(@sum_weekly_data)

        worksheet.write(start_row+5,start_column+3,"Trend Average")
        worksheet.write(start_row+6,start_column,"Portfolio")
        worksheet.write(start_row+6,start_column+1,"New Loans")
        worksheet.write(start_row+6,start_column+2,"Reloans")
        worksheet.write(start_row+6,start_column+3,"RL %")
        worksheet.write(start_row+6,start_column+4,"Total")
        worksheet.write(start_row+6,start_column+5,"Total LTD")
        worksheet.write(start_row+6,start_column+6,"Loans Out")

        worksheet.write(start_row+7,start_column,"All")
        worksheet.write(start_row+7,start_column+1,@trend_avg[:new_loan_avg])
        worksheet.write(start_row+7,start_column+2,@trend_avg[:reloan_avg])
        worksheet.write(start_row+7,start_column+3,@trend_avg[:reloan_perc_avg])
        worksheet.write(start_row+7,start_column+4,@trend_avg[:total_loan_avg])
        worksheet.write(start_row+7,start_column+5,"N/A")
        worksheet.write(start_row+7,start_column+6,@trend_avg[:loans_out_avg])

        worksheet.write(start_row+9,start_column+3,"Trend for Last 6 Weeks")
        worksheet.write(start_row+10,start_column,"Weeks")
        worksheet.write(start_row+10,start_column+1,"New Loans")
        worksheet.write(start_row+10,start_column+2,"Reloans")
        worksheet.write(start_row+10,start_column+3,"RL %")
        worksheet.write(start_row+10,start_column+4,"Total")
        worksheet.write(start_row+10,start_column+5,"Total LTD")
        worksheet.write(start_row+10,start_column+6,"Loans Out")

        position = 11
        @sum_weekly_data.each do |weekly_data|
          worksheet.write(start_row+position,start_column,weekly_data[:week_number])
          worksheet.write(start_row+position,start_column+1,weekly_data[:new_loans_today])
          worksheet.write(start_row+position,start_column+2,weekly_data[:reloans_today])
          worksheet.write(start_row+position,start_column+3,weekly_data[:reloan_percentage])
          worksheet.write(start_row+position,start_column+4,weekly_data[:total_loans_today])
          worksheet.write(start_row+position,start_column+5,weekly_data[:total_loans_to_date])
          worksheet.write(start_row+position,start_column+6,weekly_data[:loans_out_today])
          position+=1
        end
      elsif session[:trend] == "3"
        @sum_monthly_data = Array.new
        @sum_monthly_data = get_trend
        @trend_avg = get_trend_avg(@sum_monthly_data)

        worksheet.write(start_row+5,start_column+3,"Trend Average")
        worksheet.write(start_row+6,start_column,"Portfolio")
        worksheet.write(start_row+6,start_column+1,"New Loans")
        worksheet.write(start_row+6,start_column+2,"Reloans")
        worksheet.write(start_row+6,start_column+3,"RL %")
        worksheet.write(start_row+6,start_column+4,"Total")
        worksheet.write(start_row+6,start_column+5,"Total LTD")
        worksheet.write(start_row+6,start_column+6,"Loans Out")

        worksheet.write(start_row+7,start_column,"All")
        worksheet.write(start_row+7,start_column+1,@trend_avg[:new_loan_avg])
        worksheet.write(start_row+7,start_column+2,@trend_avg[:reloan_avg])
        worksheet.write(start_row+7,start_column+3,@trend_avg[:reloan_perc_avg])
        worksheet.write(start_row+7,start_column+4,@trend_avg[:total_loan_avg])
        worksheet.write(start_row+7,start_column+5,"N/A")
        worksheet.write(start_row+7,start_column+6,@trend_avg[:loans_out_avg])

        worksheet.write(start_row+9,start_column+3,"Trend for Last 6 Months")
        worksheet.write(start_row+10,start_column,"Months")
        worksheet.write(start_row+10,start_column+1,"New Loans")
        worksheet.write(start_row+10,start_column+2,"Reloans")
        worksheet.write(start_row+10,start_column+3,"RL %")
        worksheet.write(start_row+10,start_column+4,"Total")
        worksheet.write(start_row+10,start_column+5,"Total LTD")
        worksheet.write(start_row+10,start_column+6,"Loans Out")
        position = 11
        @sum_monthly_data.each do |monthly_data|
          worksheet.write(start_row+position,start_column,monthly_data[:month_name])
          worksheet.write(start_row+position,start_column+1,monthly_data[:new_loans_today])
          worksheet.write(start_row+position,start_column+2,monthly_data[:reloans_today])
          worksheet.write(start_row+position,start_column+3,monthly_data[:reloan_percentage])
          worksheet.write(start_row+position,start_column+4,monthly_data[:total_loans_today])
          worksheet.write(start_row+position,start_column+5,monthly_data[:total_loans_to_date])
          worksheet.write(start_row+position,start_column+6,monthly_data[:loans_out_today])
          position+=1
        end
      elsif session[:trend] == "4"
        @sum_yearly_data = Array.new
        @sum_yearly_data = get_trend
        @trend_avg = get_trend_avg(@sum_yearly_data)

        worksheet.write(start_row+5,start_column+3,"Trend Average")
        worksheet.write(start_row+6,start_column,"Portfolio")
        worksheet.write(start_row+6,start_column+1,"New Loans")
        worksheet.write(start_row+6,start_column+2,"Reloans")
        worksheet.write(start_row+6,start_column+3,"RL %")
        worksheet.write(start_row+6,start_column+4,"Total")
        worksheet.write(start_row+6,start_column+5,"Total LTD")
        worksheet.write(start_row+6,start_column+6,"Loans Out")

        worksheet.write(start_row+7,start_column,"All")
        worksheet.write(start_row+7,start_column+1,@trend_avg[:new_loan_avg])
        worksheet.write(start_row+7,start_column+2,@trend_avg[:reloan_avg])
        worksheet.write(start_row+7,start_column+3,@trend_avg[:reloan_perc_avg])
        worksheet.write(start_row+7,start_column+4,@trend_avg[:total_loan_avg])
        worksheet.write(start_row+7,start_column+5,"N/A")
        worksheet.write(start_row+7,start_column+6,@trend_avg[:loans_out_avg])

        worksheet.write(start_row+9,start_column+3,"Trend for Last 6 Years")
        worksheet.write(start_row+10,start_column,"Years")
        worksheet.write(start_row+10,start_column+1,"New Loans")
        worksheet.write(start_row+10,start_column+2,"Reloans")
        worksheet.write(start_row+10,start_column+3,"RL %")
        worksheet.write(start_row+10,start_column+4,"Total")
        worksheet.write(start_row+10,start_column+5,"Total LTD")
        worksheet.write(start_row+10,start_column+6,"Loans Out")
        position = 11
        @sum_yearly_data.each do |yearly_data|
          worksheet.write(start_row+position,start_column,yearly_data[:year_number])
          worksheet.write(start_row+position,start_column+1,yearly_data[:new_loans_today])
          worksheet.write(start_row+position,start_column+2,yearly_data[:reloans_today])
          worksheet.write(start_row+position,start_column+3,yearly_data[:reloan_percentage])
          worksheet.write(start_row+position,start_column+4,yearly_data[:total_loans_today])
          worksheet.write(start_row+position,start_column+5,yearly_data[:total_loans_to_date])
          worksheet.write(start_row+position,start_column+6,yearly_data[:loans_out_today])
          position+=1
        end
      end
      @filename = "export_underwriter.xls"
      workbook.close
      send_data(excel_content.string, :type => 'application/vnd.ms-excel',
        :filename => @filename,
        :disposition => 'attachment')
    end



    def set_portfolio_trend
      session[:portfolio_id] = params[:p]
      session[:trend] = params[:t]
      @portfolio_id = params[:p]
      if params[:t] == '1'
        @daily_data = Array.new
        @daily_data = get_trend
        @trend_avg = get_trend_avg(@daily_data)
      elsif params[:t] == '2'
        @sum_weekly_data = Array.new
        @sum_weekly_data = get_trend
        @trend_avg = get_trend_avg(@sum_weekly_data)
      elsif params[:t] == '3'
        @sum_monthly_data = Array.new
        @sum_monthly_data = get_trend
        @trend_avg = get_trend_avg(@sum_monthly_data)
      elsif params[:t] == '4'
        @sum_yearly_data = Array.new
        @sum_yearly_data = get_trend
        @trend_avg = get_trend_avg(@sum_yearly_data)
      end
    end

    def get_trend
      if session[:trend] == "1"
        date = get_weekdays
        @current_period = date[:current_date]
        @one_period_before = date[:one_day_before]
        @two_period_before = date[:two_day_before]
        @three_period_before = date[:three_day_before]
        @four_period_before = date[:four_day_before]
        @five_period_before = date[:five_day_before]
      elsif session[:trend] == "2"
        @current_period = Date.today.to_date - 7
        @one_period_before = @current_period - 7
        @two_period_before = @one_period_before - 7
        @three_period_before = @two_period_before - 7
        @four_period_before = @three_period_before - 7
        @five_period_before = @four_period_before - 7
      elsif session[:trend] == "3"
        @current_period = Date.today.to_date << 1
        @one_period_before = @current_period << 1
        @two_period_before = @one_period_before << 1
        @three_period_before = @two_period_before << 1
        @four_period_before = @three_period_before << 1
        @five_period_before = @four_period_before << 1
      elsif session[:trend] == "4"
        @current_period = Date.today.to_date.year - 1
        @one_period_before = @current_period - 1
        @two_period_before = @one_period_before - 1
        @three_period_before = @two_period_before - 1
        @four_period_before = @three_period_before - 1
        @five_period_before = @four_period_before - 1
      end
      @trend_period = []
      @trend_period[0] = @current_period
      @trend_period[1] = @one_period_before
      @trend_period[2] = @two_period_before
      @trend_period[3] = @three_period_before
      @trend_period[4] = @four_period_before
      @trend_period[5] = @five_period_before

      @period_data = Array.new
      @sum_weekly = Array.new
      @sum_monthly = Array.new
      @sum_yearly = Array.new

      for i in (0..5)

        @new_loan_period = 0
        @reloan_period = 0
        @reloan_perc_period = 0
        @total_loan_period = 0
        @total_LTD_period = 0
        @loans_out_period = 0

        if session[:trend] == "1"
          @period_data << PortfolioSnapshot.find_by_snapshot_on_and_portfolio_id(@trend_period[i],session[:portfolio_id])
        elsif session[:trend] == "2"
          @period_data = PortfolioSnapshot.find(:all, :conditions => { :snapshot_on => @trend_period[i].beginning_of_week .. @trend_period[i].end_of_week, :portfolio_id => session[:portfolio_id] })
        elsif session[:trend] == "3"
          @period_data = PortfolioSnapshot.find(:all, :conditions => { :snapshot_on => @trend_period[i].beginning_of_month .. @trend_period[i].end_of_month, :portfolio_id => session[:portfolio_id] })
        elsif session[:trend] == "4"
          @period_data = PortfolioSnapshot.find(:all, :conditions => ["YEAR(snapshot_on) =? AND portfolio_id =?", @trend_period[i], session[:portfolio_id] ])
        end
        @period_data = @period_data.compact
        if session[:trend] != "1"
          j = 0
          @period_data.each do |period_data|
            @new_loan_period += period_data.new_loans_today
            @reloan_period += period_data.reloans_today
            @reloan_perc_period += period_data.reloan_percentage
            @total_loan_period += period_data.total_loans_today
            @total_LTD_period += period_data.total_loans_to_date
            @loans_out_period += period_data.loans_out_today
            j+=1
          end
          if j == 0
            @reloan_perc_period = 0
          else
            @reloan_perc_period = @reloan_perc_period / j
          end
          if session[:trend] == "2"
            @sum_weekly << {
              :new_loans_today => @new_loan_period,
              :reloans_today => @reloan_period,
              :reloan_percentage => @reloan_perc_period,
              :total_loans_today => @total_loan_period,
              :total_loans_to_date => @total_LTD_period,
              :loans_out_today => @loans_out_period,
              :week_number => @trend_period[i].strftime('%W')
            }
          elsif session[:trend] == "3"
            @sum_monthly << {
              :new_loans_today => @new_loan_period,
              :reloans_today => @reloan_period,
              :reloan_percentage => @reloan_perc_period,
              :total_loans_today => @total_loan_period,
              :total_loans_to_date => @total_LTD_period,
              :loans_out_today => @loans_out_period,
              :month_name => @trend_period[i].strftime('%B')
            }
          elsif session[:trend] == "4"
            @sum_yearly << {
              :new_loans_today => @new_loan_period,
              :reloans_today => @reloan_period,
              :reloan_percentage => @reloan_perc_period,
              :total_loans_today => @total_loan_period,
              :total_loans_to_date => @total_LTD_period,
              :loans_out_today => @loans_out_period,
              :year_number => @trend_period[i]
            }
          end
        end
      end
      if session[:trend] == "1"
        return @period_data
      elsif session[:trend] == "2"
        return @sum_weekly
      elsif session[:trend] == "3"
        return @sum_monthly
      elsif session[:trend] == "4"
        return @sum_yearly
      end
    end

    def get_trend_avg(trend_data)

      @new_loan_avg = 0
      @reloan_avg = 0
      @reloan_perc_avg = 0
      @total_loan_avg = 0
      @loans_out_avg = 0

      trend_data.each do |trend|
        if not trend[:new_loans_today] == 0
          @new_loan_avg += trend[:new_loans_today]
        end
        if not trend[:reloans_today] == 0
          @reloan_avg += trend[:reloans_today]
        end
        if not trend[:reloan_percentage] == 0
          @reloan_perc_avg += trend[:reloan_percentage]
        end
        if not trend[:total_loans_today] == 0
          @total_loan_avg += trend[:total_loans_today]
        end
        if not trend[:loans_out_today] == 0
          @loans_out_avg += trend[:loans_out_today]
        end
      end

      if not @new_loan_avg == 0
        @new_loan_avg = @new_loan_avg/6
      end
      if not @reloan_avg == 0
        @reloan_avg = @reloan_avg/6
      end
      if not @reloan_perc_avg == 0
        @reloan_perc_avg = @reloan_perc_avg/6
      end
      if not @total_loan_avg == 0
        @total_loan_avg = @total_loan_avg/6
      end
      if not @loans_out_avg == 0
        @loans_out_avg = @loans_out_avg/6
      end

      {:new_loan_avg => @new_loan_avg, :reloan_avg => @reloan_avg, :reloan_perc_avg => @reloan_perc_avg, :total_loan_avg => @total_loan_avg, :loans_out_avg => @loans_out_avg}
    end

    def get_weekdays
      @current_date = Date.today.to_date - 1
      if @current_date.strftime('%a') == 'Mon'
        @one_day_before = @current_date - 3
        @two_day_before = @one_day_before - 1
        @three_day_before = @two_day_before - 1
        @four_day_before = @three_day_before - 1
        @five_day_before = @four_day_before - 1
      elsif @current_date.strftime('%a') == 'Tue'
        @one_day_before = @current_date - 1
        @two_day_before = @one_day_before - 3
        @three_day_before = @two_day_before - 1
        @four_day_before = @three_day_before - 1
        @five_day_before = @four_day_before - 1
      elsif @current_date.strftime('%a') == 'Wed'
        @one_day_before = @current_date - 1
        @two_day_before = @one_day_before - 1
        @three_day_before = @two_day_before - 3
        @four_day_before = @three_day_before - 1
        @five_day_before = @four_day_before - 1
      elsif @current_date.strftime('%a') == 'Thu'
        @one_day_before = @current_date - 1
        @two_day_before = @one_day_before - 1
        @three_day_before = @two_day_before - 1
        @four_day_before = @three_day_before - 3
        @five_day_before = @four_day_before - 1
      elsif @current_date.strftime('%a') == 'Fri'
        @one_day_before = @current_date - 1
        @two_day_before = @one_day_before - 1
        @three_day_before = @two_day_before - 1
        @four_day_before = @three_day_before - 1
        @five_day_before = @four_day_before - 3
      end
      {:current_date => @current_date, :one_day_before => @one_day_before, :two_day_before => @two_day_before, :three_day_before => @three_day_before, :four_day_before => @four_day_before, :five_day_before => @five_day_before}
    end

    def financial
      @financial = "This is Financial Report" #this is just a notification. you can remove it.
    end

    def performance_member_data_calculation(date_string)
      session[:date_string] = date_string
      team_members = User.find(:all,:conditions=>["team_id=?",current_user.team_id])
      if date_string.include? "-"
        date_range = date_string.split("-")
        start_date  = date_range[0].to_date
        end_date    = date_range[1].to_date
        days_between_dates = end_date - start_date
      else
        selected_date = date_string.blank? ? Date.today : date_string.to_date
      end
      #****************************** Start Of Members Loan Data ****************************************************

      team_member_loans = Array.new
      team_report_data = Array.new

      approved_loan_count = 0
      loan_rejected = 0
      approved_loan_per_hour = 0
      approved_loan_per_day = 0
      percentage_of_loan_approved = 0.0
      loan_collections_on = 0

      loan_funded_on = 0.0
      percentage_funded_on = 0.0

      for team_member in team_members
        approved_loan_count = 0
        loan_rejected = 0
        approved_loan_per_hour = 0
        approved_loan_per_day = 0
        percentage_of_loan_approved = 0.0
        loan_collections_on = 0
        loan_funded_on = 0.0
        percentage_funded_on = 0.0

        if date_string.include? "-"
          team_member_loans =  Loan.find_all_by_underwriter_id(team_member.id,:conditions=>["DATE(created_at) between ? and ? ",start_date,end_date])
        else
          team_member_loans =  Loan.find_all_by_underwriter_id(team_member.id,:conditions=>["DATE(created_at)=?", selected_date])
        end

        team_member_loans = team_member_loans.compact
        for team_member_loan in team_member_loans

          #****************************** Start Calculation for Approved Loan *******************************************

          if team_member_loan.approved_at
            if  date_string.include? "-"
              if (  (team_member_loan.approved_at.to_date >= start_date) &&
                    (team_member_loan.approved_at.to_date <= end_date))
                approved_loan_count = approved_loan_count + 1
              end
            else
              if team_member_loan.approved_at.to_date == selected_date
                approved_loan_count = approved_loan_count + 1
              end
            end
          end
          #**************************************** End Calculation for Approved Loan *************************************************************************************

          #**************************************** Start Count for Rejected Loan *******************************************
          if team_member_loan.aasm_state == "denied"
            loan_rejected = loan_rejected + 1
          end
          #**************************************** End count for Rejected Loan ******************************************

          #if not team_member_loan.collections_on.nil?
          #***************************************  Start Count for collection Loan ********************************************
          if team_member_loan.collections_on
            if  date_string.include? "-"
              if team_member_loan.collections_on.to_date >= start_date &&
                  team_member_loan.collections_on.to_date <= end_date
                loan_collections_on = loan_collections_on + 1
              end
            else
              if team_member_loan.collections_on.to_date ==  selected_date
                loan_collections_on = loan_collections_on + 1
              end
            end
          end
          #************************ End Count for Collection Loan ************************************

          #*********************** Start Count for funded Loan    ***********************************
          if team_member_loan.funded_on
            if  date_string.include? "-"
              if ((team_member_loan.funded_on.to_date >= start_date) &&
                    (team_member_loan.funded_on.to_date <= end_date))
                loan_funded_on = loan_funded_on + 1
              end
            else
              if team_member_loan.funded_on ==  selected_date
                loan_funded_on = loan_funded_on + 1
              end
            end
          end
          #************************** End Count for Funded Loan ******************************************
        end
        # ************************ Start count for Approved Loan per Day ******************************
        if date_string.include? '-'
          if approved_loan_count == 0
            approved_loan_per_day = 0.to_f
          else
            approved_loan_per_day = approved_loan_count.to_f / days_between_dates
          end
        else
          approved_loan_per_day = approved_loan_count.to_f
        end

        #************************ End Count for Approved Loann Per Day *******************************

        #************************ Start Count For Approved Loan Per Hour *****************************

        if  approved_loan_count == 0
          approved_loan_per_hour = 0
        elsif  date_string.include? "-"
          perday =  approved_loan_count / days_between_dates
          approved_loan_per_hour = perday.to_f / 8
        else
          approved_loan_per_hour = approved_loan_count.to_f / 8
        end
        #************************** End Count For Approved Loann Per Hour *****************************

        #************************** Start count of % field *******************************************
        if loan_collections_on == 0  || loan_funded_on == 0
          percentage_funded_on = 0.0
        else
          percentage_funded_on = (loan_collections_on / loan_funded_on) * 100.0
        end
        #************************** End count of % field  *******************************************

        #*************************  Start Count For Percentage Loan Approved **************************
        if approved_loan_count == 0 || team_member_loans.size == 0
          percentage_of_loan_approved = 0.0
        else
          percentage_of_loan_approved =  (approved_loan_count * 100) / team_member_loans.size
        end
        #************************* End Count For Percentage Loan Approved   ***************************

        team_report_data  << {
          :id => team_member.id,
          :first_name=>team_member.first_name,
          :member_loan_count => team_member_loans.size,
          :loan_approved => approved_loan_count,
          :approved_loan_per_hour => approved_loan_per_hour,
          :approved_loan_per_day => approved_loan_per_day,
          :loan_rejected=>loan_rejected,
          :loan_collections_on=>loan_collections_on,
          :percentage_of_loan_approved=> percentage_of_loan_approved.to_f,
          :percentage_funded_on=>percentage_funded_on.to_f
        }

      end
      return team_report_data
    end

    def export_performance_csv

      @get_team_performance_data = performance_member_data_calculation(session[:date_string])
      @get_all_department_performance_data = department_performance_data(@get_team_performance_data)
      #params[:data] = @get_all_deparment_performance_data
      #exit
      csv_string = FasterCSV.generate do |csv|
        csv << ["","","","Department"]
        csv << ["Name","Apps","Yes","Hour","Day","Conv.","No","1stD","%"]

          csv << [
            "All",
            @get_all_department_performance_data[:department_wise_loan],
            @get_all_department_performance_data[:department_wise_loan_approved],
            @get_all_department_performance_data[:department_wise_loan_approved_per_hour],
            @get_all_department_performance_data[:department_wise_loan_approved_per_day],
            @get_all_department_performance_data[:department_wise_percentage].to_s+"%",
            @get_all_department_performance_data[:deparment_wise_loan_rejecet],
            @get_all_department_performance_data[:department_wise_loan_collections_on],
            @get_all_department_performance_data[:department_wise_loan_funded_on].to_f
          ]

        csv << ["","","","My Team"]
        csv << ["Name","Apps","Yes","Hour","Day","Conv.","No","1stD","%"]

        @get_team_performance_data.each do |get_team_performance_data|
          csv << [
            get_team_performance_data[:first_name],
            get_team_performance_data[:member_loan_count],
            get_team_performance_data[:loan_approved],
            get_team_performance_data[:approved_loan_per_hour],
            get_team_performance_data[:approved_loan_per_day],
            get_team_performance_data[:percentage_of_loan_approved].to_s+"%",
            get_team_performance_data[:loan_rejected],
            get_team_performance_data[:loan_collections_on],
            get_team_performance_data[:percentage_funded_on].to_f
          ]
        end
      end
      send_data csv_string,:type => "text/csv", :filename=>"export_performance_data.csv", :disposition => 'attachment'
    end


    def department_performance_data(department_performance_alldata)
      department_wise_loan = 0
      #all_department_wise_loann_approved = 0
      department_wise_loan_approved = 0
      department_wise_loan_approved_per_hour = 0
      department_wise_loan_approved_per_day = 0
      department_wise_percentage = 0.0
      deparment_wise_loan_rejecet = 0
      department_wise_loan_collections_on = 0
      department_wise_loan_funded_on = 0.0


      #@department_wise_data = Array.new
      department_performance_alldata.each do |department_performance_data|
        department_wise_loan = department_wise_loan + department_performance_data[:member_loan_count]
        department_wise_loan_approved = department_wise_loan_approved + department_performance_data[:loan_approved]
        department_wise_loan_approved_per_hour = department_wise_loan_approved_per_hour + department_performance_data[:approved_loan_per_hour]
        department_wise_loan_approved_per_day = department_wise_loan_approved_per_day + department_performance_data[:approved_loan_per_day]
        department_wise_percentage = department_wise_percentage + department_performance_data[:percentage_of_loan_approved]
        deparment_wise_loan_rejecet = deparment_wise_loan_rejecet + department_performance_data[:loan_rejected]
        department_wise_loan_collections_on = department_wise_loan_collections_on + department_performance_data[:loan_collections_on]
        department_wise_loan_funded_on = department_wise_loan_funded_on + department_performance_data[:percentage_funded_on]
      end
      {
        :department_wise_loan=>department_wise_loan,
        :department_wise_loan_approved=>department_wise_loan_approved,
        :department_wise_loan_approved_per_hour=>department_wise_loan_approved_per_hour,
        :department_wise_loan_approved_per_day=>department_wise_loan_approved_per_day,
        :department_wise_percentage=>department_wise_percentage,
        :deparment_wise_loan_rejecet=>deparment_wise_loan_rejecet,
        :department_wise_loan_collections_on=>department_wise_loan_collections_on,
        :department_wise_loan_funded_on=>department_wise_loan_funded_on.to_f
      }
    end

    def underwriting_department_performance_data(date_string)
      if date_string.include? "-"
        date_range = date_string.split("-")
        start_date  = date_range[0].to_date
        end_date    = date_range[1].to_date
        days = (end_date - start_date) + 1
        loans = Loan.find(:all,:conditions=>["DATE(created_at) between ? and ? ",start_date,end_date])
      else
        selected_date = date_string.blank? ? Date.today : date_string.to_date
        days = 1
        loans = Loan.find(:all,:conditions=>["DATE(created_at)=?",selected_date])
      end

      underwriter_ids = []
      approved = 0
      denied = 0
      defaulted = 0
      loans.each do |loan|
        underwriter_ids << loan.underwriter_id unless underwriter_ids.include? loan.underwriter_id

        if loan.approved_at
          if  date_string.include? "-"
            if (  (loan.approved_at.to_date >= start_date) &&
                  (loan.approved_at.to_date <= end_date))
              approved += 1
            end
          else
            if loan.approved_at.to_date == selected_date
              approved += 1
            end
          end
        end

        if loan.aasm_state == "denied"
          denied += 1
        end

        if loan.approved_at && loan.funded_on && loan.collections_on
          if  date_string.include? "-"
            if loan.collections_on.to_date >= start_date &&
                loan.collections_on.to_date <= end_date
              defaulted += 1
            end
          else
            if loan.collections_on.to_date ==  selected_date
              defaulted += 1
            end
          end
        end

      end # loans loop

      num_underwriters = underwriter_ids.size
      num_loans = loans.size
      avg_approved_per_underwriter_per_hour = approved.to_f / (num_underwriters * 8)
      avg_approved_per_underwriter_per_day = approved.to_f / ( days * num_underwriters)
      avg_approved_per_day = approved.to_f / days
      avg_approved_per_hour = approved.to_f / ( days * 8)
      avg_approved_pct_per_underwriter = approved.to_f / num_underwriters
      avg_default_pct_per_underwriter = defaulted.to_f / num_underwriters
      conversion_ratio = (approved.to_f / num_loans) * 100.0
      default_percentage = (defaulted.to_f / approved) * 100.0

      [
        {
          :label => 'Total',
          :loans => num_loans,
          :approved => approved,
          :per_hour => avg_approved_per_hour,
          :per_day => avg_approved_per_day,
          :conversion_ratio => conversion_ratio,
          :denied => denied.to_f,
          :defaulted => defaulted.to_f,
          :default_percentage => default_percentage
        },
        {
          :label => 'Average',
          :loans => num_loans.to_f / num_underwriters,
          :approved => approved.to_f / num_underwriters,
          :per_hour => approved.to_f / (num_underwriters * 8),
          :per_day => approved.to_f / ( days * num_underwriters),
          :conversion_ratio => conversion_ratio,
          :denied => denied.to_f / num_underwriters,
          :defaulted => defaulted.to_f / num_underwriters,
          :default_percentage => default_percentage
        }
      ]
    end


    def performance
      @get_team_performance_data = performance_member_data_calculation("")
      @get_all_deparment_performance_data = department_performance_data(@get_team_performance_data)
      @department_performance_data = underwriting_department_performance_data("")
      logger.info "dept. perf. data: #{@department_performance_data.inspect}"
    end

    def performance_asper_selectdate
      @get_team_performance_data = performance_member_data_calculation(params[:selectdate])
      logger.info "TEAM PERFORMANCE DATA: #{@get_team_performance_data.inspect}"
      @get_all_deparment_performance_data = department_performance_data(@get_team_performance_data)
      @department_performance_data = underwriting_department_performance_data(params[:selectdate])
    end

    def investors
      @investors = "This is Investors Report" #this is just a notification. you can remove it.
    end


    def collection_marketing
      @collection_market = "This is Collection Marketing Report" #this is just a notification. you can remove it.
    end

    def collection_portfolio
      @collection_portfolio = "This is Collection Portfolio Report" #this is just a notification. you can remove it.
    end

    def collection_financial
      @collection_financial = "This is Collection Financial Report" #this is just a notification. you can remove it.
    end

    def collection_performance
      @collection_performance = "This is Collection Performance Report" #this is just a notification. you can remove it.
    end

    def collection_investors
      @collection_investors = "This is Collection Investors Report" #this is just a notification. you can remove it.
    end


    def garnishments_marketing
      @garnishments_market = "This is Garnishments Marketing Report" #this is just a notification. you can remove it.
    end

    def garnishments_portfolio
      @garnishments_portfolio = "This is Garnishments Portfolio Report" #this is just a notification. you can remove it.
    end

    def garnishments_financial
      @garnishments_financial = "This is Garnishments Financial Report" #this is just a notification. you can remove it.
    end

    def garnishments_performance
      @garnishments_performance = "This is Garnishments Performance Report" #this is just a notification. you can remove it.
    end

    def garnishments_investors
      @garnishments_investors = "This is Garnishments Investors Report" #this is just a notification. you can remove it.
    end

    def portfolio_snapshot
      @portfolios = Portfolio.all
      @portfolios.each do |@portfolio|
        @port = PortfolioSnapshot.new
        @port.portfolio_id = @portfolio.id
        @port.new_loans_today = Loan.count(:all,:conditions=>["portfolio_id=? && reloan=? && funded_on=?",@portfolio.id,false,Date.today.to_date - 1])
        @port.reloans_today = Loan.count(:all,:conditions=>["portfolio_id=? && reloan=? && funded_on=?",@portfolio.id,true,Date.today.to_date - 1])
        @port.total_loans_today = @port.new_loans_today + @port.reloans_today
        if @port.total_loans_today == 0
          @port.reloan_percentage = 0
        else
          @port.reloan_percentage = ((@port.reloans_today)/(@port.total_loans_today)*(100))
        end

        @port.total_loans_to_date = @port.total_loans_today - Loan.count(:all, :conditions => ["portfolio_id=? && funded_on=?",@portfolio,Date.today.to_date - 2])
        @port.loans_out_today = Loan.count(:all, :conditions => ["portfolio_id=? && funded_on =? && aasm_state not in (?)",@portfolio,Date.today.to_date - 1,["paid_in_full","written_off"]])
        @port.snapshot_on = Date.today.to_date - 1
        @port.save
      end
    end

    # Reminders
    def reminders
      case current_user.role
      when 'administrator'
        if params[:filters] && !params[:filters][:user_id].blank?
          user = User.find(params[:filters][:user_id])
          reminders = user.reminders
        else
          reminders = Reminder.find(:all)
        end
      else
        reminders = current_user.reminders
      end
      @reminders = reminders.paginate(:page => params[:page], :per_page => 15, :include => :loan)
    end
  end
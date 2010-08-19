module LoansHelper
  def lastworked(loan)
    diff_in_sec = (Time.now - loan.updated_at).round
    mins = diff_in_sec / 60
    hours = mins / 60
    if(hours > 8)
      link_to loan.customer.full_name, loan_path(loan),{:style => "color: red;", :title => "Last Updated: #{loan.updated_at.to_s(:day_date_time)}"}
    elsif (hours > 6)
      link_to loan.customer.full_name, loan_path(loan),{:style => "color: #ff6600;", :title => "Last Updated: #{loan.updated_at.to_s(:day_date_time)}"}
    elsif (hours > 4)
      link_to loan.customer.full_name, loan_path(loan),{:style => "color: orange;", :title => "Last Updated: #{loan.updated_at.to_s(:day_date_time)}"}
    elsif (hours > 2)
      link_to loan.customer.full_name, loan_path(loan),{:style => "color: #ffcc00;", :title => "Last Updated: #{loan.updated_at.to_s(:day_date_time)}"}
    else
      link_to loan.customer.full_name, loan_path(loan),{:title => "Last Updated: #{loan.updated_at.to_s(:day_date_time)}"}
    end
  end

  def garnishments_lastworked(loan)
    days = Date.today - loan.updated_at.to_date
    if(days >= 6)
      link_to loan.customer.full_name, loan_path(loan),{:title => "Last Updated: #{loan.updated_at.to_s(:day_date_time)}"}
    elsif (days >= 4)
      link_to loan.customer.full_name, loan_path(loan),{:title => "Last Updated: #{loan.updated_at.to_s(:day_date_time)}"}
    elsif (days >= 2)
      link_to loan.customer.full_name, loan_path(loan),{:title => "Last Updated: #{loan.updated_at.to_s(:day_date_time)}"}
    else
      link_to loan.customer.full_name, loan_path(loan),{:title => "Last Updated: #{loan.updated_at.to_s(:day_date_time)}"}
    end
  end

  def next_scheduled_payment_date(loan)
    if loan.scheduled_payments.first
      return loan.scheduled_payments.first.draft_date.to_s(:m_d_y)
    end
    "None"
  end

  def garnishment_sub_status_display(loan)
    words = loan.garnishment_sub_status.split('_')
    display = ''
    words.each do |word|
      display += ' ' unless display.blank?
      display += word.capitalize
    end
    display
  end

  def garnishment_telephone_status_icon(loan)
    case loan.garnishment_telephone_status
    when 'no_answer'
      return image_tag("/images/silk/telephone_error.png",:border => 0)
    when 'left_message'
      return image_tag("/images/silk/vcard.png",:border => 0)
    end
    image_tag("/images/icons/bullet_black.png",:border => 0)
  end
end

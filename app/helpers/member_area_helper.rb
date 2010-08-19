module MemberAreaHelper
  
  def loan_status(loan)
    if ['pending_signature','underwriting','active','paid_in_fuill'].include? loan.aasm_state
      color = 'green'
    else
      color = 'red'
    end
    "<span style=\"color:#{color};font-weight:bold\">#{loan.aasm_state_to_text}</span>"
  end

  def loan_date(loan)
    return loan.funded_on if loan.funded_on
    return loan.approved_at if loan.approved_at
    loan.created_at
  end

  def loan_status_alert(loan)
    case loan.aasm_state
    when 'underwriting'
      return "Please call (866) 569-3321 to finalize your loan."
    when 'approved'
      return "Your loan has been approved. Funds should be in your account tomorrow."
    when 'active'
      next_payment = loan.next_payment
      return "Your next payment of #{number_to_currency(next_payment[:amount], :precision => 2)}<br /> will be submitted on #{next_payment[:date].to_s(:sm_d_y)}."
    when 'paid_in_full'
      return "You may apply for a new loan here."
    when 'collections','garnishments'
      return "Please contact us immediately at (866) 569-3321 to bring your account current."
    end
  end
end

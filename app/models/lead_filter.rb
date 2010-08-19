class LeadFilter < ActiveRecord::Base
  has_many :lead_providers
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :minimum_months_at_job, :minimum_months_at_bank, :minimum_age, :minimum_factor_trust_score
  
  def destroyable?
    lead_providers.length == 0
  end
  
  def pass?(customer)
    errors = []
    if (self.minimum_months_at_job > customer.months_employed)
      errors << "months_employed is not acceptable"
    end
    if (self.minimum_months_at_bank > customer.months_at_bank)
      errors << "months_at_bank is not acceptable"
    end
    if (self.minimum_age > customer.age)
      errors << "birth_date is not acceptable - must be #{self.minimum_age} years old"
    end
    if ((customer.pay_frequency == "WEEKLY"       && !self.allow_pay_frequency_weekly) ||
        (customer.pay_frequency == "BIWEEKLY"     && !self.allow_pay_frequency_biweekly) ||
        (customer.pay_frequency == "TWICEMONTHLY" && !self.allow_pay_frequency_monthly) ||
        (customer.pay_frequency == "MONTHLY"      && !self.allow_pay_frequency_twice_per_month))
      errors << "pay_frequency is not acceptable"
    end
    if (customer.income_source == "BENEFITS" && !self.allow_payroll_type_benefits)
      errors << "income_source is not acceptable"
    end
    if (customer.income_source == "EMPLOYMENT")
      if (customer.bank_direct_deposit == true && !self.allow_payroll_type_direct_deposit)
        errors << "income_source is not acceptable"
      elsif (customer.bank_direct_deposit == false && self.allow_payroll_type_direct_deposit)
        errors << "income_source is not acceptable"
      end
    end
    return errors
  end
  
end

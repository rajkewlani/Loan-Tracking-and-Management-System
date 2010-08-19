class CreateLeadFilters < ActiveRecord::Migration
  def self.up
    create_table :lead_filters do |t|
      t.string  :name, :null => false
      t.integer :minimum_months_at_job
      t.integer :minimum_months_at_bank
      t.integer :minimum_age
      t.boolean :allow_pay_frequency_weekly
      t.boolean :allow_pay_frequency_biweekly
      t.boolean :allow_pay_frequency_monthly
      t.boolean :allow_pay_frequency_twice_per_month
      t.boolean :allow_payroll_type_cash
      t.boolean :allow_payroll_type_check
      t.boolean :allow_payroll_type_direct_deposit
      t.boolean :allow_payroll_type_benefits
      t.integer :minimum_factor_trust_score
      t.timestamps
    end
  end

  def self.down
    drop_table :lead_filters
  end
end

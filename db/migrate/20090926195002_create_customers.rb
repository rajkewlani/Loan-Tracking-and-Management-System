class CreateCustomers < ActiveRecord::Migration
  def self.up
    create_table :customers do |t|
      t.integer   :lead_provider_id,                           :null => false, :default => 0
      t.integer   :portfolio_id,                               :null => false
      t.string    :ip_address,               :limit => 20,     :null => false
      t.string    :lead_source,              :limit => 100#,    :null => false
      t.string    :tracker_id
      t.boolean   :relaxed_validation,                         :null => false, :default => false
      t.string    :first_name,               :limit => 30,     :null => false
      t.string    :middle_name,              :limit => 30
      t.string    :last_name,                :limit => 30,     :null => false
      t.string    :mothers_maiden_name,      :limit => 30
      t.string    :encrypted_ssn,                              :null => false
      t.string    :gender,                   :limit => 1
      t.string    :email,                    :limit => 50#,     :null => false
      t.date      :birth_date#,                                 :null => false
      t.binary    :encrypted_dl_number#,                        :null => false
      t.string    :dl_state,                 :limit => 2#,      :null => false
      t.boolean   :military,                                   :null => false,  :default => false
      t.string    :home_phone,               :limit => 10#,     :null => false
      t.string    :work_phone,               :limit => 10#,     :null => false
      t.string    :cell_phone,               :limit => 10
      t.boolean   :do_not_call_home,                                            :default => false
      t.boolean   :do_not_call_work,                                            :default => false
      t.boolean   :do_not_call_cell,                                            :default => false
      t.string    :fax,                      :limit => 10
      t.string    :address,                  :limit => 30#,     :null => false
      t.string    :city,                     :limit => 30#,     :null => false
      t.string    :state,                    :limit => 2#,      :null => false
      t.string    :zip,                      :limit => 5#,      :null => false
      t.string    :country_code,             :limit => 2,      :null => false
      t.string    :time_zone,                                  :null => false
      t.boolean   :time_zone_geocoded,                                          :default => false
      t.string    :best_time_to_call
      t.string    :language
      t.integer   :monthly_income,                             :null => false,  :default => 0
      t.string    :income_source,            :limit => 20,     :null => false
      t.string    :pay_frequency,            :limit => 20,     :null => false
      t.string    :employer_name,            :limit => 30#,     :null => false
      t.string    :occupation,               :limit => 100
      t.integer   :months_employed,                            :null => false
      t.string    :employer_address,         :limit => 30
      t.string    :employer_city,            :limit => 30
      t.string    :employer_state,           :limit => 2
      t.string    :employer_zip,             :limit => 5
      t.string    :employer_phone,           :limit => 10#,     :null => false
      t.string    :employer_phone_ext,       :limit => 5
      t.string    :employer_fax,             :limit => 10
      t.string    :supervisor_name,          :limit => 30
      t.string    :supervisor_phone,         :limit => 10
      t.string    :supervisor_phone_ext,     :limit => 5
      t.string    :residence_type,           :limit => 4,      :null => false
      t.integer   :monthly_residence_cost,                     :null => false
      t.integer   :months_at_address,                          :null => false
      t.string    :landlord_name,            :limit => 50
      t.string    :landlord_phone,           :limit => 10
      t.string    :landlord_address,         :limit => 30
      t.string    :landlord_city,            :limit => 30
      t.string    :landlord_state,           :limit => 2
      t.string    :landlord_zip,             :limit => 5
      t.boolean   :contact_by_mail,                                             :default => true
      t.boolean   :contact_by_email,                                            :default => true
      t.boolean   :contact_by_sms,                                              :default => true
      t.date      :next_pay_date_1#,                            :null => false
      t.date      :next_pay_date_2#,                            :null => false
      t.decimal   :credit_limit,                               :null => false
      t.string    :reference_1_name,         :limit => 50#,     :null => false
      t.string    :reference_1_phone,        :limit => 10#,     :null => false
      t.string    :reference_1_address,      :limit => 30
      t.string    :reference_1_city,         :limit => 30
      t.string    :reference_1_state,        :limit => 2
      t.string    :reference_1_zip,          :limit => 5
      t.string    :reference_1_relationship, :limit => 20#,     :null => false
      t.string    :reference_2_name,         :limit => 50#,     :null => false
      t.string    :reference_2_phone,        :limit => 10#,     :null => false
      t.string    :reference_2_address,      :limit => 30
      t.string    :reference_2_city,         :limit => 30
      t.string    :reference_2_state,        :limit => 2
      t.string    :reference_2_zip,          :limit => 5
      t.string    :reference_2_relationship, :limit => 20#,     :null => false
      t.string    :authnet_customer_profile_id
      t.boolean   :is_test,                                                   :default => false
      t.string    :aasm_state,                                                :default => "not_purchased"
      t.integer   :manually_entered_by
      t.string    :reject_reason
      t.boolean   :send_sms_messages,                          :null => false, :default => false
      t.boolean   :send_marketing_emails,                      :null => false, :default => false
      t.boolean   :send_prerecorded_messages,                  :null => false, :default => false
      t.string    :password_hash
      t.string    :password_salt
      t.boolean   :reset_password_at_next_login,               :null => false, :default => false
      t.boolean   :login_suspended,                            :null => false, :default => false
      t.timestamps
    end

    add_index :customers, :encrypted_ssn

  end

  def self.down
    drop_table :customers
  end
end

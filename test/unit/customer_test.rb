require File.dirname(__FILE__) + '/../test_helper'

class CustomerTest < Test::Unit::TestCase

  should_allow_mass_assignment_of :ip_address, :lead_source, :tracker_id, :first_name, :last_name,
                                  :ssn, :gender, :email, :birth_date, :dl_number, :dl_state, 
                                  :military, :home_phone, :cell_phone, :fax, :address, :city, 
                                  :state, :zip, :monthly_income, :income_source, :pay_frequency, 
                                  :employer_name, :occupation, :months_employed, :employer_address, 
                                  :employer_city, :employer_state, :employer_zip, :employer_phone, 
                                  :employer_phone_ext, :supervisor_name, :supervisor_phone, 
                                  :supervisor_phone_ext, :residence_type, :monthly_residence_cost, 
                                  :months_at_address, :landlord_name, :landlord_phone, :landlord_address,
                                  :landlord_city, :landlord_state, :landlord_zip, :contact_by_mail, 
                                  :contact_by_email, :contact_by_sms, :bank_name, :bank_account_type, 
                                  :bank_aba_number, :bank_account_number, :months_at_bank, 
                                  :bank_direct_deposit, :bank_address, :bank_city, :bank_state, 
                                  :bank_zip, :bank_phone, :bank_account_balance, :number_of_nsf, 
                                  :number_of_transactions, :next_pay_date_1, :next_pay_date_2, 
                                  :loan_amount, :reference_1_name, :reference_1_phone, :reference_1_address, 
                                  :reference_1_city, :reference_1_state, :reference_1_zip, 
                                  :reference_1_relationship, :reference_2_name, :reference_2_phone, 
                                  :reference_2_address, :reference_2_city, :reference_2_state, 
                                  :reference_2_zip, :reference_2_relationship, :is_test               
  
  should_validate_presence_of :lead_provider_id
  should_validate_presence_of :ip_address
  should_allow_values_for :ip_address, "135.23.66.76", "74.125.53.104"
  should_not_allow_values_for :ip_address, "127.0.0.1", "0.0.0.0", "a.b.c.d"
  should_validate_presence_of :lead_source
  should_validate_presence_of :first_name
  should_ensure_length_in_range :first_name, (1..30), :short_message => /can't be blank/
  should_validate_presence_of :last_name
  should_ensure_length_in_range :last_name, (1..30), :short_message => /can't be blank/
  should_validate_presence_of :ssn
  should_allow_values_for :gender, "m", "f", "", nil
  should_not_allow_values_for :gender, "M", "Male", "Alien"
  should_validate_presence_of :email
  should_not_allow_values_for :email, "blah", "b lah" 
  should_allow_values_for :email, "a@b.com", "asdf@asdf.com"
  should_ensure_length_in_range :email, (6..50)
  should_validate_presence_of :birth_date
  should_not_allow_values_for :birth_date, (Date.today - 15.years), nil
  should_allow_values_for :birth_date, (Date.today - 21.years), (Date.today - 40.years)
  should_validate_presence_of :dl_number
  should_validate_presence_of :dl_state
  should_not_allow_values_for :dl_state, "US", "GEORGIA"
  should_allow_values_for :dl_state, "UT", "CA", "WY"
  should_validate_presence_of :home_phone
  should_ensure_length_is :home_phone, 10
  should_validate_numericality_of :home_phone
  should_allow_values_for :cell_phone, "8013364689", "", nil
  should_not_allow_values_for :cell_phone, "531-3515", "801-361-2223", "18013515151"
  should_allow_values_for :fax, "8013364689", "", nil
  should_not_allow_values_for :fax, "531-3515", "801-361-2223", "18013515151"
  should_validate_presence_of :address
  should_ensure_length_in_range :address, (1..30), :short_message => /can't be blank/
  should_validate_presence_of :city
  should_ensure_length_in_range :city, (1..30), :short_message => /can't be blank/
  should_validate_presence_of :state
  should_not_allow_values_for :state, "US", "GEORGIA"
  should_allow_values_for :state, "UT", "CA", "WY"
  should_validate_presence_of :zip
  should_ensure_length_is :zip, 5
  should_validate_numericality_of :zip
  should_validate_presence_of :monthly_income
  should_validate_presence_of :income_source
  should_not_allow_values_for :income_source, "MOM", "DAD", "85"
  should_allow_values_for :income_source, "EMPLOYMENT", "BENEFITS"
  should_validate_presence_of :pay_frequency
  should_not_allow_values_for :pay_frequency, "EVERY NOW AND THEN", " "
  should_allow_values_for :pay_frequency, "WEEKLY", "BIWEEKLY", "TWICEMONTHLY", "MONTHLY"
  should_validate_presence_of :employer_name
  should_ensure_length_in_range :employer_name, (1..30), :short_message => /can't be blank/
  should_validate_presence_of :months_employed
  should_ensure_length_in_range :employer_address, (0..30), :short_message => /can't be blank/
  should_ensure_length_in_range :employer_city, (0..30), :short_message => /can't be blank/
  should_not_allow_values_for :employer_state, "US", "GEORGIA"
  should_allow_values_for :employer_state, "UT", "CA", "WY", "", nil
  should_not_allow_values_for :employer_zip, "166460", "8816", "ABCDE"
  should_allow_values_for :employer_zip, "70135", "89120", "", nil
  should_validate_presence_of :employer_phone
  should_ensure_length_is :employer_phone, 10
  should_validate_numericality_of :employer_phone
  should_not_allow_values_for :employer_phone_ext, "166460", "abcde f"
  should_allow_values_for :employer_phone_ext, "10015", "x 120", "", nil
  should_ensure_length_in_range :supervisor_name, (0..30), :short_message => /can't be blank/
  should_allow_values_for :supervisor_phone, "8013364689", "", nil
  should_not_allow_values_for :supervisor_phone, "531-3515", "801-361-2223", "18013515151"
  should_allow_values_for :supervisor_phone_ext, "10015", "x 120", "", nil
  should_not_allow_values_for :supervisor_phone_ext, "166460", "abcde f"
  should_validate_presence_of :residence_type
  should_allow_values_for :residence_type, "RENT", "OWN"
  should_not_allow_values_for :residence_type, "BORROW", "INHABIT", "POSSESS"
  should_validate_presence_of :monthly_residence_cost
  should_validate_presence_of :months_at_address
  should_allow_values_for :landlord_phone, "8013364689", "", nil
  should_not_allow_values_for :landlord_phone, "531-3515", "801-361-2223", "18013515151"
  should_ensure_length_in_range :landlord_address, (0..30)
  should_ensure_length_in_range :landlord_city, (0..30)
  should_not_allow_values_for :landlord_state, "US", "GEORGIA"
  should_allow_values_for :landlord_state, "UT", "CA", "WY"
  should_ensure_length_is :landlord_zip, 5
  should_validate_numericality_of :landlord_zip
  should_validate_presence_of :bank_name
  should_ensure_length_in_range :bank_name, (1..30), :short_message => /can't be blank/
  should_validate_presence_of :bank_account_type
  should_allow_values_for :bank_account_type, "CHECKING", "SAVINGS"
  should_not_allow_values_for :bank_account_type, "UNDER BED", "WALL SAFE", "WALLET"
  should_validate_presence_of :bank_aba_number
  should_validate_presence_of :bank_account_number
  should_validate_presence_of :months_at_bank
  should_allow_values_for :bank_direct_deposit, true, false
  should_not_allow_values_for :bank_direct_deposit, nil
  should_ensure_length_in_range :bank_address, (0..30)
  should_ensure_length_in_range :bank_city, (0..30)
  should_not_allow_values_for :bank_state, "US", "GEORGIA"
  should_allow_values_for :bank_state, "UT", "CA", "WY"
  should_ensure_length_is :bank_zip, 5
  should_validate_numericality_of :bank_zip
  should_allow_values_for :bank_phone, "8013364689", "", nil
  should_not_allow_values_for :bank_phone, "531-3515", "801-361-2223", "18013515151"
  should_validate_presence_of :next_pay_date_1
  # should_allow_values_for :next_pay_date_1, Date.today, (Date.today + 1.week)
  # should_not_allow_values_for :next_pay_date_1, (Date.today - 1.day), (Date.today + 4.months)
  # should_allow_values_for :next_pay_date_2, (Date.today + 3.weeks)
  should_validate_presence_of :reference_1_name
  should_ensure_length_in_range :reference_1_name, (1..50), :short_message => /can't be blank/
  should_validate_presence_of :reference_1_phone
  should_ensure_length_is :reference_1_phone, 10
  should_validate_numericality_of :reference_1_phone
  should_ensure_length_in_range :reference_1_address, (0..30), :short_message => /can't be blank/
  should_ensure_length_in_range :reference_1_city, (0..30), :short_message => /can't be blank/
  should_not_allow_values_for :reference_1_state, "US", "GEORGIA"
  should_allow_values_for :reference_1_state, "UT", "CA", "WY", "", nil
  should_not_allow_values_for :reference_1_zip, "166460", "8816", "ABCDE"
  should_allow_values_for :reference_1_zip, "70135", "89120", "", nil
  should_validate_presence_of :reference_2_name
  should_ensure_length_in_range :reference_2_name, (1..50), :short_message => /can't be blank/
  should_validate_presence_of :reference_2_phone
  should_ensure_length_is :reference_2_phone, 10
  should_validate_numericality_of :reference_2_phone
  should_ensure_length_in_range :reference_2_address, (0..30), :short_message => /can't be blank/
  should_ensure_length_in_range :reference_2_city, (0..30), :short_message => /can't be blank/
  should_not_allow_values_for :reference_2_state, "US", "GEORGIA"
  should_allow_values_for :reference_2_state, "UT", "CA", "WY", "", nil
  should_not_allow_values_for :reference_2_zip, "166460", "8816", "ABCDE"
  should_allow_values_for :reference_2_zip, "70135", "89120", "", nil
  
  context "A new customer" do
    
    setup do
      @customer = Customer.new
    end
    
#    should "encrypt and decrypt dl_number" do
#      @customer.dl_number = "123456"
#      assert_equal "*encrypted*", @customer.dl_number.to_s
#      assert_equal "123456", @customer.dl_number
#    end
    
#    should "encrypt and decrypt bank_aba_number and bank_account_number" do
#      @customer.bank_aba_number = "112233445"
#      @customer.bank_account_number = "885588558855"
#      assert_equal "*encrypted*", @customer.bank_aba_number.to_s
#      assert_equal "*encrypted*", @customer.bank_account_number.to_s
#      assert_equal "112233445", @customer.bank_aba_number
#      assert_equal "885588558855", @customer.bank_account_number
#    end
    
  end

end

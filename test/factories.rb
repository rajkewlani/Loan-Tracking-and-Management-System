Factory.define :lead_filter do |f|
  f.name                                "Default Filter"
  f.minimum_months_at_job               3
  f.minimum_months_at_bank              2
  f.minimum_age                         21
  f.allow_pay_frequency_weekly          false
  f.allow_pay_frequency_biweekly        true
  f.allow_pay_frequency_monthly         true
  f.allow_pay_frequency_twice_per_month true
  f.allow_payroll_type_cash             false
  f.allow_payroll_type_check            false
  f.allow_payroll_type_direct_deposit   true
  f.allow_payroll_type_benefits         false
  f.minimum_factor_trust_score          650
end

Factory.define :lead_provider do |f|
  f.name                  "Test Lead Provider"
  f.username              "provider_1"
  f.password              "provider_1"
  f.lead_filter_id        1
  f.status                0
  f.primary_contact       "Eric Berry"
  f.primary_contact_email "cavneb@gmail.com"
  f.primary_contact_phone "8015556467"
end

Factory.define :customer, :class => Customer do |f|
  f.lead_provider_id         1
  f.ip_address               "72.26.62.76"
  f.lead_source                   "website.com"
  f.tracker_id               "1300"
  f.first_name               "Joe"
  f.last_name                "Blow"
  f.ssn                      "391336213"
  f.gender                   "m"
  f.email                    "jblow@website.com"
  f.birth_date               "1973-03-15"
  f.dl_number                "315316317"
  f.dl_state                 "UT"
  f.military                 false
  f.home_phone               "8015551111"
  f.cell_phone               "8015552222"
  f.fax                      "8015553333"
  f.address                  "123 Easy St"
  f.city                     "Herriman"
  f.state                    "UT"
  f.zip                      "84096"
  f.monthly_income           "3250"
  f.income_source            "EMPLOYMENT"
  f.pay_frequency            "TWICEMONTHLY"
  f.employer_name            "Wizbang Cogs, Inc"
  f.occupation               "Technician"
  f.months_employed          7
  f.employer_address         "8131 Constitution Rd"
  f.employer_city            "WestJordan"
  f.employer_state           "UT"
  f.employer_zip             "84088"
  f.employer_phone           "8015554444"
  f.employer_phone_ext       ""
  f.supervisor_name          "Sally Stanford"
  f.supervisor_phone         "8015555555"
  f.supervisor_phone_ext     ""
  f.residence_type           "RENT"
  f.monthly_residence_cost   1250
  f.months_at_address        12
  f.bank_name                "US Bank"
  f.bank_account_type        "CHECKING"
  f.bank_aba_number          "012345678"
  f.bank_account_number      "99313"
  f.months_at_bank           36
  f.bank_direct_deposit      true
  f.bank_address             "1300 S Temple"
  f.bank_city                "Salt Lake City"
  f.bank_state               "UT"
  f.bank_zip                 "89331"
  f.bank_phone               "8015556666"
  f.next_pay_date_1          "2009-10-30"
  f.next_pay_date_2          "2009-11-15"
  f.reference_1_relationship "COWORKER"
  f.reference_1_name         "Gary Chattersworth"
  f.reference_1_phone        "8015557777"
  f.reference_1_address      "55 N Epson Ave"
  f.reference_1_city         "Las Vegas"
  f.reference_1_state        "NV"
  f.reference_1_zip          "89147"
  f.reference_2_relationship "SIBLING"
  f.reference_2_name         "Lionel Luther"
  f.reference_2_phone        "8015558888"
  f.reference_2_address      "118 Bloom St"
  f.reference_2_city         "Sandy"
  f.reference_2_state        "UT"
  f.reference_2_zip          "83059"
  f.loan_amount              300
end
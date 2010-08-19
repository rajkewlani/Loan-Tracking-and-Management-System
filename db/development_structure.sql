CREATE TABLE `ach_batches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ach_provider_id` int(11) DEFAULT NULL,
  `credits` int(11) DEFAULT NULL,
  `credit_amount` decimal(15,2) DEFAULT '0.00',
  `debits` int(11) DEFAULT NULL,
  `debit_amount` decimal(15,2) DEFAULT '0.00',
  `file_name` varchar(255) DEFAULT NULL,
  `csv` text,
  `batch_date` date DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_ach_batches_on_created_at` (`created_at`),
  KEY `fk_ach_batches_ach_provider_id` (`ach_provider_id`),
  CONSTRAINT `fk_ach_batches_ach_provider_id` FOREIGN KEY (`ach_provider_id`) REFERENCES `ach_providers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `ach_providers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(40) NOT NULL,
  `login_id` varchar(255) DEFAULT NULL,
  `origin_id` varchar(255) DEFAULT NULL,
  `processing_email` varchar(255) DEFAULT NULL,
  `support_email` varchar(255) DEFAULT NULL,
  `support_phone` varchar(255) DEFAULT NULL,
  `primary_contact_name` varchar(255) DEFAULT NULL,
  `primary_contact_phone` varchar(255) DEFAULT NULL,
  `primary_contact_email` varchar(255) DEFAULT NULL,
  `alternate_contact_name` varchar(255) DEFAULT NULL,
  `alternate_contact_phone` varchar(255) DEFAULT NULL,
  `alternate_contact_email` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

CREATE TABLE `ach_returns` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ach_provider_id` int(11) NOT NULL,
  `company_identifier` varchar(255) DEFAULT NULL,
  `company_name` varchar(255) DEFAULT NULL,
  `ee_date` varchar(255) DEFAULT NULL,
  `transaction_code` int(11) DEFAULT NULL,
  `routing_number` varchar(255) NOT NULL,
  `account_number` varchar(255) NOT NULL,
  `amount` decimal(10,0) NOT NULL,
  `loan_id` int(11) NOT NULL,
  `customer_name` varchar(255) NOT NULL,
  `return_reason_code` varchar(255) NOT NULL,
  `correction_info` varchar(255) DEFAULT NULL,
  `loan_transaction_id` int(11) NOT NULL,
  `processed_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_ach_returns_on_loan_transaction_id` (`loan_transaction_id`),
  KEY `fk_ach_returns_ach_provider_id` (`ach_provider_id`),
  KEY `index_ach_returns_on_loan_id` (`loan_id`),
  KEY `index_ach_returns_on_processed_at` (`processed_at`),
  CONSTRAINT `fk_ach_returns_ach_provider_id` FOREIGN KEY (`ach_provider_id`) REFERENCES `ach_providers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `ach_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ach_batch_id` int(11) DEFAULT NULL,
  `loan_id` int(11) DEFAULT NULL,
  `store_id` int(11) DEFAULT NULL,
  `company_name` varchar(255) DEFAULT NULL,
  `sec` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `effective_date` varchar(255) DEFAULT NULL,
  `individual` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `receiving_routing_number` varchar(255) DEFAULT NULL,
  `receiving_account_number` varchar(255) DEFAULT NULL,
  `transaction_code` int(11) DEFAULT NULL,
  `amount` varchar(255) DEFAULT NULL,
  `optional_1` varchar(20) DEFAULT NULL,
  `optional_2` varchar(2) DEFAULT NULL,
  `trace_number` varchar(15) DEFAULT NULL,
  `status_code` varchar(1) DEFAULT NULL,
  `reason` varchar(30) DEFAULT NULL,
  `corrective_information` varchar(35) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `bank_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) NOT NULL,
  `bank_name` varchar(30) NOT NULL,
  `bank_account_type` varchar(8) NOT NULL,
  `encrypted_bank_aba_number` varchar(255) NOT NULL,
  `encrypted_bank_account_number` varchar(255) NOT NULL,
  `months_at_bank` int(11) NOT NULL,
  `bank_direct_deposit` tinyint(1) NOT NULL,
  `bank_address` varchar(30) DEFAULT NULL,
  `bank_city` varchar(30) DEFAULT NULL,
  `bank_state` varchar(2) DEFAULT NULL,
  `bank_zip` varchar(5) DEFAULT NULL,
  `bank_phone` varchar(10) DEFAULT NULL,
  `bank_account_balance` decimal(10,2) DEFAULT NULL,
  `number_of_nsf` int(11) DEFAULT '0',
  `number_of_transactions` int(11) DEFAULT '0',
  `funding_account` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=461 DEFAULT CHARSET=latin1;

CREATE TABLE `comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(50) DEFAULT '',
  `comment` text,
  `commentable_id` int(11) DEFAULT NULL,
  `commentable_type` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_comments_on_commentable_type` (`commentable_type`),
  KEY `index_comments_on_commentable_id` (`commentable_id`),
  KEY `index_comments_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=534 DEFAULT CHARSET=latin1;

CREATE TABLE `countries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `code` varchar(255) NOT NULL,
  `max_apr` float DEFAULT NULL,
  `max_loan_amount` decimal(10,0) DEFAULT NULL,
  `min_loan_days` int(11) DEFAULT NULL,
  `max_loan_days` int(11) DEFAULT NULL,
  `max_loans_per_year` int(11) DEFAULT NULL,
  `max_extensions` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_countries_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

CREATE TABLE `credit_cards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `card_type` varchar(8) NOT NULL,
  `encrypted_last_4_digits` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `customer_phone_listings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) NOT NULL,
  `phone` varchar(10) NOT NULL,
  `owner` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `company` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `state` varchar(2) DEFAULT NULL,
  `zip` varchar(20) DEFAULT NULL,
  `line_type` varchar(255) DEFAULT NULL,
  `provider` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_customer_phone_listings_customer_id` (`customer_id`),
  CONSTRAINT `fk_customer_phone_listings_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=301 DEFAULT CHARSET=latin1;

CREATE TABLE `customers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lead_provider_id` int(11) NOT NULL DEFAULT '0',
  `portfolio_id` int(11) NOT NULL,
  `ip_address` varchar(20) NOT NULL,
  `lead_source` varchar(100) NOT NULL,
  `tracker_id` varchar(255) DEFAULT NULL,
  `first_name` varchar(30) NOT NULL,
  `middle_name` varchar(30) DEFAULT NULL,
  `last_name` varchar(30) NOT NULL,
  `mothers_maiden_name` varchar(30) DEFAULT NULL,
  `encrypted_ssn` varchar(255) NOT NULL,
  `gender` varchar(1) DEFAULT NULL,
  `email` varchar(50) NOT NULL,
  `birth_date` date NOT NULL,
  `encrypted_dl_number` blob NOT NULL,
  `dl_state` varchar(2) NOT NULL,
  `military` tinyint(1) NOT NULL DEFAULT '0',
  `home_phone` varchar(10) NOT NULL,
  `work_phone` varchar(10) NOT NULL,
  `cell_phone` varchar(10) DEFAULT NULL,
  `fax` varchar(10) DEFAULT NULL,
  `address` varchar(30) NOT NULL,
  `city` varchar(30) NOT NULL,
  `state` varchar(2) NOT NULL,
  `zip` varchar(5) NOT NULL,
  `country_code` varchar(2) NOT NULL,
  `best_time_to_call` varchar(255) DEFAULT NULL,
  `monthly_income` int(11) NOT NULL,
  `income_source` varchar(20) NOT NULL,
  `pay_frequency` varchar(20) NOT NULL,
  `employer_name` varchar(30) NOT NULL,
  `occupation` varchar(100) DEFAULT NULL,
  `months_employed` int(11) NOT NULL,
  `employer_address` varchar(30) DEFAULT NULL,
  `employer_city` varchar(30) DEFAULT NULL,
  `employer_state` varchar(2) DEFAULT NULL,
  `employer_zip` varchar(5) DEFAULT NULL,
  `employer_phone` varchar(10) NOT NULL,
  `employer_phone_ext` varchar(5) DEFAULT NULL,
  `employer_fax` varchar(10) DEFAULT NULL,
  `supervisor_name` varchar(30) DEFAULT NULL,
  `supervisor_phone` varchar(10) DEFAULT NULL,
  `supervisor_phone_ext` varchar(5) DEFAULT NULL,
  `residence_type` varchar(4) NOT NULL,
  `monthly_residence_cost` int(11) NOT NULL,
  `months_at_address` int(11) NOT NULL,
  `landlord_name` varchar(50) DEFAULT NULL,
  `landlord_phone` varchar(10) DEFAULT NULL,
  `landlord_address` varchar(30) DEFAULT NULL,
  `landlord_city` varchar(30) DEFAULT NULL,
  `landlord_state` varchar(2) DEFAULT NULL,
  `landlord_zip` varchar(5) DEFAULT NULL,
  `contact_by_mail` tinyint(1) DEFAULT '1',
  `contact_by_email` tinyint(1) DEFAULT '1',
  `contact_by_sms` tinyint(1) DEFAULT '1',
  `next_pay_date_1` date NOT NULL,
  `next_pay_date_2` date NOT NULL,
  `credit_limit` decimal(10,0) NOT NULL,
  `reference_1_name` varchar(50) NOT NULL,
  `reference_1_phone` varchar(10) NOT NULL,
  `reference_1_address` varchar(30) DEFAULT NULL,
  `reference_1_city` varchar(30) DEFAULT NULL,
  `reference_1_state` varchar(2) DEFAULT NULL,
  `reference_1_zip` varchar(5) DEFAULT NULL,
  `reference_1_relationship` varchar(20) NOT NULL,
  `reference_2_name` varchar(50) NOT NULL,
  `reference_2_phone` varchar(10) NOT NULL,
  `reference_2_address` varchar(30) DEFAULT NULL,
  `reference_2_city` varchar(30) DEFAULT NULL,
  `reference_2_state` varchar(2) DEFAULT NULL,
  `reference_2_zip` varchar(5) DEFAULT NULL,
  `reference_2_relationship` varchar(20) NOT NULL,
  `authnet_customer_profile_id` varchar(255) DEFAULT NULL,
  `is_test` tinyint(1) DEFAULT '0',
  `aasm_state` varchar(255) DEFAULT 'not_purchased',
  `reject_reason` varchar(255) DEFAULT NULL,
  `send_sms_messages` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_customers_on_encrypted_ssn` (`encrypted_ssn`)
) ENGINE=InnoDB AUTO_INCREMENT=461 DEFAULT CHARSET=latin1;

CREATE TABLE `delayed_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `priority` int(11) DEFAULT '0',
  `attempts` int(11) DEFAULT '0',
  `handler` text,
  `last_error` text,
  `run_at` datetime DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `failed_at` datetime DEFAULT NULL,
  `locked_by` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `documents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `loan_id` int(11) DEFAULT NULL,
  `owner_type` varchar(255) DEFAULT 'Customer',
  `description` varchar(255) DEFAULT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `filename` varchar(255) DEFAULT NULL,
  `thumbnail` varchar(255) DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `factor_trusts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) NOT NULL,
  `response_xml` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_factor_trusts_on_customer_id` (`customer_id`),
  CONSTRAINT `fk_factor_trusts_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=461 DEFAULT CHARSET=latin1;

CREATE TABLE `high_risk_bank_branches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `aba_routing_number` varchar(9) NOT NULL,
  `name` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_high_risk_bank_branches_on_aba_routing_number` (`aba_routing_number`),
  KEY `index_high_risk_bank_branches_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `investments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `investor_id` int(11) NOT NULL,
  `portfolio_id` int(11) NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_investments_investor_id` (`investor_id`),
  KEY `fk_investments_portfolio_id` (`portfolio_id`),
  CONSTRAINT `fk_investments_investor_id` FOREIGN KEY (`investor_id`) REFERENCES `investors` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_investments_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `portfolios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=latin1;

CREATE TABLE `investors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `investor_name` varchar(255) NOT NULL,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `password_salt` varchar(255) DEFAULT NULL,
  `authorization_token` varchar(255) DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `last_login_ip` varchar(255) DEFAULT NULL,
  `logged_in` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_investors_on_email` (`email`),
  UNIQUE KEY `index_investors_on_authorization_token` (`authorization_token`),
  KEY `index_investors_on_last_name` (`last_name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

CREATE TABLE `lead_filters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `minimum_months_at_job` int(11) DEFAULT NULL,
  `minimum_months_at_bank` int(11) DEFAULT NULL,
  `minimum_age` int(11) DEFAULT NULL,
  `allow_pay_frequency_weekly` tinyint(1) DEFAULT NULL,
  `allow_pay_frequency_biweekly` tinyint(1) DEFAULT NULL,
  `allow_pay_frequency_monthly` tinyint(1) DEFAULT NULL,
  `allow_pay_frequency_twice_per_month` tinyint(1) DEFAULT NULL,
  `allow_payroll_type_cash` tinyint(1) DEFAULT NULL,
  `allow_payroll_type_check` tinyint(1) DEFAULT NULL,
  `allow_payroll_type_direct_deposit` tinyint(1) DEFAULT NULL,
  `allow_payroll_type_benefits` tinyint(1) DEFAULT NULL,
  `minimum_factor_trust_score` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

CREATE TABLE `lead_providers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `lead_filter_id` int(11) NOT NULL,
  `status` int(11) NOT NULL DEFAULT '0',
  `primary_contact` varchar(255) DEFAULT NULL,
  `primary_contact_email` varchar(255) DEFAULT NULL,
  `primary_contact_phone` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;

CREATE TABLE `loan_snapshots` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `loan_id` int(11) NOT NULL,
  `principal_owed` decimal(10,0) NOT NULL,
  `interest_owed` decimal(10,0) NOT NULL,
  `fees_owed` decimal(10,0) NOT NULL,
  `aasm_state` varchar(255) NOT NULL,
  `created_on` date NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_loan_snapshots_on_created_on` (`created_on`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `loan_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `loan_id` int(11) NOT NULL,
  `ach_batch_id` int(11) DEFAULT NULL,
  `tran_type` varchar(255) NOT NULL,
  `total` decimal(15,2) DEFAULT '0.00',
  `principal` decimal(15,2) DEFAULT '0.00',
  `interest` decimal(15,2) DEFAULT '0.00',
  `fees` decimal(15,2) DEFAULT '0.00',
  `failed_total` decimal(15,2) DEFAULT '0.00',
  `nsf` tinyint(1) NOT NULL DEFAULT '0',
  `account_closed` tinyint(1) NOT NULL DEFAULT '0',
  `check_number` int(11) DEFAULT NULL,
  `ach_return_code` varchar(255) DEFAULT NULL,
  `ach_return_reason` varchar(255) DEFAULT NULL,
  `payment_account_id` int(11) DEFAULT NULL,
  `new_due_date` date DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_loan_transactions_loan_id` (`loan_id`),
  CONSTRAINT `fk_loan_transactions_loan_id` FOREIGN KEY (`loan_id`) REFERENCES `loans` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=latin1;

CREATE TABLE `loans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) NOT NULL,
  `portfolio_id` int(11) NOT NULL,
  `underwriter_id` int(11) DEFAULT NULL,
  `underwriter_type` varchar(255) DEFAULT 'User',
  `collections_agent_id` int(11) DEFAULT NULL,
  `collections_agent_type` varchar(255) DEFAULT 'User',
  `garnishments_agent_id` int(11) DEFAULT NULL,
  `garnishments_agent_type` varchar(255) DEFAULT 'User',
  `garnishments_approved_at` datetime DEFAULT NULL,
  `garnishment_packet_sent_at` datetime DEFAULT NULL,
  `garnishment_sub_status` varchar(255) DEFAULT NULL,
  `paying` tinyint(1) DEFAULT '0',
  `due_date` date DEFAULT NULL,
  `auto_extend_to_upon_funding` date DEFAULT NULL,
  `requested_loan_amount` decimal(15,2) NOT NULL,
  `apr` float NOT NULL,
  `principal_owed` decimal(15,2) DEFAULT NULL,
  `interest_owed` decimal(15,2) DEFAULT NULL,
  `fees_owed` decimal(15,2) DEFAULT NULL,
  `amounts_owed_updated_on` date DEFAULT NULL,
  `aasm_state` varchar(255) DEFAULT NULL,
  `reject_reason` varchar(255) DEFAULT NULL,
  `max_loan_amount` decimal(15,2) DEFAULT NULL,
  `min_loan_days` int(11) DEFAULT NULL,
  `max_loan_days` int(11) DEFAULT NULL,
  `max_extensions` int(11) DEFAULT NULL,
  `max_loans_per_year` int(11) NOT NULL DEFAULT '52',
  `disclosed_finance_charge_amount_at` datetime DEFAULT NULL,
  `disclosed_due_date_at` datetime DEFAULT NULL,
  `disclosed_apr_at` datetime DEFAULT NULL,
  `disclosed_extend_12_weeks_max_at` datetime DEFAULT NULL,
  `disclosed_partial_payments_at` datetime DEFAULT NULL,
  `disclosed_recission_at` datetime DEFAULT NULL,
  `disclosed_must_request_extensions_at` datetime DEFAULT NULL,
  `disclosed_member_area_at` datetime DEFAULT NULL,
  `signature_page_loan_amount` decimal(15,2) NOT NULL,
  `signature_page_finance_charge` decimal(15,2) DEFAULT NULL,
  `signature_token` varchar(255) DEFAULT NULL,
  `signature_page_arrived_at` datetime DEFAULT NULL,
  `signature_page_accepted_at` datetime DEFAULT NULL,
  `signature_page_ip_address` varchar(255) DEFAULT NULL,
  `signature_page_accepted_name` varchar(255) DEFAULT NULL,
  `verified_personal` tinyint(1) DEFAULT '0',
  `verified_financial` tinyint(1) DEFAULT '0',
  `verified_employment_with_customer` tinyint(1) DEFAULT '0',
  `verified_employment_with_employer` tinyint(1) DEFAULT '0',
  `verified_tila` tinyint(1) DEFAULT '0',
  `approved_at` datetime DEFAULT NULL,
  `approved_loan_amount` decimal(15,2) DEFAULT NULL,
  `funded_on` date DEFAULT NULL,
  `financial_data_change` tinyint(1) DEFAULT '0',
  `reloan` tinyint(1) DEFAULT NULL,
  `paid_in_full_on` date DEFAULT NULL,
  `recission_requested_on` date DEFAULT NULL,
  `recission_draft_on` date DEFAULT NULL,
  `recission_draft_ach_batch_id` int(11) DEFAULT NULL,
  `defaulted_on` date DEFAULT NULL,
  `collections_on` date DEFAULT NULL,
  `garnishments_on` date DEFAULT NULL,
  `written_off_on` date DEFAULT NULL,
  `remark` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_loans_on_signature_token` (`signature_token`),
  KEY `fk_loans_customer_id` (`customer_id`),
  KEY `fk_loans_portfolio_id` (`portfolio_id`),
  KEY `index_loans_on_defaulted_on` (`defaulted_on`),
  CONSTRAINT `fk_loans_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_loans_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `portfolios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=461 DEFAULT CHARSET=latin1;

CREATE TABLE `locations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `ip_address` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_locations_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;

CREATE TABLE `locations_users` (
  `location_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  UNIQUE KEY `index_locations_users_on_location_id_and_user_id` (`location_id`,`user_id`),
  KEY `fk_locations_users_user_id` (`user_id`),
  CONSTRAINT `fk_locations_users_location_id` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_locations_users_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `log_details` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `log_id` int(11) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `detail` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message` text,
  `loggable_id` int(11) DEFAULT NULL,
  `loggable_type` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `group` varchar(255) DEFAULT NULL,
  `owner_id` int(11) DEFAULT NULL,
  `owner_type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_logs_on_loggable_id` (`loggable_id`),
  KEY `index_logs_on_loggable_type` (`loggable_type`),
  KEY `index_logs_on_user_id` (`user_id`),
  KEY `index_logs_on_owner_id` (`owner_id`),
  KEY `index_logs_on_owner_type` (`owner_type`)
) ENGINE=InnoDB AUTO_INCREMENT=607 DEFAULT CHARSET=latin1;

CREATE TABLE `mail_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `body` text,
  `description` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `message_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

CREATE TABLE `message_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `message_categories_id` int(11) DEFAULT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `email_body` text,
  `sms_body` text,
  `description` varchar(255) DEFAULT NULL,
  `msg_event` varchar(255) DEFAULT NULL,
  `send_schedule_flag` varchar(255) DEFAULT NULL,
  `days` int(11) DEFAULT NULL,
  `before_after` varchar(255) DEFAULT NULL,
  `base_date` varchar(255) DEFAULT NULL,
  `send_hour` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=latin1;

CREATE TABLE `payment_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `account_type` varchar(255) NOT NULL,
  `authnet_payment_profile_id` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_payment_accounts_customer_id` (`customer_id`),
  CONSTRAINT `fk_payment_accounts_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=461 DEFAULT CHARSET=latin1;

CREATE TABLE `pending_ach_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `loan_id` int(11) DEFAULT NULL,
  `store_id` int(11) DEFAULT NULL,
  `company_name` varchar(255) DEFAULT NULL,
  `sec` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `effective_date` date DEFAULT NULL,
  `individual` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `receiving_routing_number` varchar(255) DEFAULT NULL,
  `receiving_account_number` varchar(255) DEFAULT NULL,
  `transaction_code` int(11) DEFAULT NULL,
  `amount` varchar(255) DEFAULT NULL,
  `optional_1` varchar(20) DEFAULT NULL,
  `optional_2` varchar(2) DEFAULT NULL,
  `trace_number` varchar(15) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_pending_ach_transactions_loan_id` (`loan_id`),
  CONSTRAINT `fk_pending_ach_transactions_loan_id` FOREIGN KEY (`loan_id`) REFERENCES `loans` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `portfolio_snapshots` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `portfolio_id` int(11) NOT NULL,
  `new_loans_today` int(11) NOT NULL,
  `reloans_today` int(11) NOT NULL,
  `total_loans_today` int(11) NOT NULL,
  `reloan_percentage` float NOT NULL,
  `loans_out_today` int(11) NOT NULL,
  `total_loans_to_date` int(11) NOT NULL,
  `snapshot_on` date NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_portfolio_snapshots_portfolio_id` (`portfolio_id`),
  KEY `index_portfolio_snapshots_on_snapshot_on` (`snapshot_on`),
  CONSTRAINT `fk_portfolio_snapshots_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `portfolios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=latin1;

CREATE TABLE `portfolios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `ceiling_amount` decimal(15,2) NOT NULL,
  `apr` float NOT NULL DEFAULT '664.84',
  `max_loan_amount` decimal(15,2) NOT NULL DEFAULT '500.00',
  `min_loan_days` int(11) NOT NULL DEFAULT '3',
  `max_loan_days` int(11) NOT NULL DEFAULT '84',
  `max_extensions` int(11) NOT NULL DEFAULT '11',
  `max_loans_per_year` int(11) NOT NULL DEFAULT '52',
  `port_key` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_portfolios_on_created_at` (`created_at`),
  KEY `index_portfolios_on_ceiling_amount` (`ceiling_amount`),
  KEY `index_portfolios_on_port_key` (`port_key`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

CREATE TABLE `scheduled_ach_drafts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `loan_id` int(11) NOT NULL,
  `bank_account_id` int(11) NOT NULL,
  `draft_date` date NOT NULL,
  `amount` decimal(10,0) NOT NULL,
  `principal` decimal(10,0) NOT NULL DEFAULT '0',
  `interest` decimal(10,0) NOT NULL DEFAULT '0',
  `fees` decimal(10,0) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_scheduled_ach_drafts_loan_id` (`loan_id`),
  CONSTRAINT `fk_scheduled_ach_drafts_loan_id` FOREIGN KEY (`loan_id`) REFERENCES `loans` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `scheduled_payments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) NOT NULL,
  `loan_id` int(11) NOT NULL,
  `payment_account_id` int(11) NOT NULL,
  `draft_date` date NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `principal` decimal(15,2) NOT NULL DEFAULT '0.00',
  `interest` decimal(15,2) NOT NULL DEFAULT '0.00',
  `fees` decimal(15,2) NOT NULL DEFAULT '0.00',
  `due_date_before_extension` date DEFAULT NULL,
  `aasm_state` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_scheduled_payments_on_loan_id_and_draft_date` (`loan_id`,`draft_date`),
  CONSTRAINT `fk_scheduled_payments_loan_id` FOREIGN KEY (`loan_id`) REFERENCES `loans` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `apr` float NOT NULL DEFAULT '664.84',
  `max_new_customer_credit_limit` int(11) NOT NULL DEFAULT '300',
  `max_credit_limit` int(11) NOT NULL DEFAULT '1500',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

CREATE TABLE `states` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `code` varchar(255) NOT NULL,
  `max_apr` float DEFAULT NULL,
  `max_loan_amount` decimal(10,0) DEFAULT NULL,
  `min_loan_days` int(11) DEFAULT NULL,
  `max_loan_days` int(11) DEFAULT NULL,
  `max_loans_per_year` int(11) DEFAULT NULL,
  `max_extensions` int(11) DEFAULT NULL,
  `country_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_states_on_country_id_and_code` (`country_id`,`code`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

CREATE TABLE `teams` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `role` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

CREATE TABLE `underwriter_verifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) NOT NULL,
  `underwriter_id` int(11) NOT NULL,
  `verification_type` varchar(255) NOT NULL,
  `notes` text,
  `status` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_underwriter_verifications_customer_id` (`customer_id`),
  CONSTRAINT `fk_underwriter_verifications_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `user_comment_notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `author_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `comment_id` int(11) NOT NULL,
  `short_message` varchar(255) DEFAULT NULL,
  `mark_as_read` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_user_comment_notifications_comment_id` (`comment_id`),
  KEY `fk_user_comment_notifications_user_id` (`user_id`),
  CONSTRAINT `fk_user_comment_notifications_comment_id` FOREIGN KEY (`comment_id`) REFERENCES `comments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_comment_notifications_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `password_salt` varchar(255) DEFAULT NULL,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  `authorization_token` varchar(255) DEFAULT NULL,
  `team_id` int(11) DEFAULT NULL,
  `manager` tinyint(1) NOT NULL DEFAULT '0',
  `available` tinyint(1) NOT NULL DEFAULT '1',
  `last_login_at` datetime DEFAULT NULL,
  `last_login_ip` varchar(255) DEFAULT NULL,
  `logged_in` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_username` (`username`),
  UNIQUE KEY `index_users_on_email` (`email`),
  UNIQUE KEY `index_users_on_authorization_token` (`authorization_token`),
  KEY `index_users_on_team_id` (`team_id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=latin1;

INSERT INTO schema_migrations (version) VALUES ('20090926195002');

INSERT INTO schema_migrations (version) VALUES ('20090927202353');

INSERT INTO schema_migrations (version) VALUES ('20090927205518');

INSERT INTO schema_migrations (version) VALUES ('20091004185307');

INSERT INTO schema_migrations (version) VALUES ('20091004212657');

INSERT INTO schema_migrations (version) VALUES ('20091005001148');

INSERT INTO schema_migrations (version) VALUES ('20091010181354');

INSERT INTO schema_migrations (version) VALUES ('20091010223000');

INSERT INTO schema_migrations (version) VALUES ('20091010224144');

INSERT INTO schema_migrations (version) VALUES ('20091011203829');

INSERT INTO schema_migrations (version) VALUES ('20091014002532');

INSERT INTO schema_migrations (version) VALUES ('20091014014214');

INSERT INTO schema_migrations (version) VALUES ('20091015012212');

INSERT INTO schema_migrations (version) VALUES ('20091017163301');

INSERT INTO schema_migrations (version) VALUES ('20100127234506');

INSERT INTO schema_migrations (version) VALUES ('20100128175748');

INSERT INTO schema_migrations (version) VALUES ('20100218141122');

INSERT INTO schema_migrations (version) VALUES ('20100223214354');

INSERT INTO schema_migrations (version) VALUES ('20100225160800');

INSERT INTO schema_migrations (version) VALUES ('20100225195334');

INSERT INTO schema_migrations (version) VALUES ('20100304180232');

INSERT INTO schema_migrations (version) VALUES ('20100309203306');

INSERT INTO schema_migrations (version) VALUES ('20100310155215');

INSERT INTO schema_migrations (version) VALUES ('20100311012523');

INSERT INTO schema_migrations (version) VALUES ('20100312011427');

INSERT INTO schema_migrations (version) VALUES ('20100401102310');

INSERT INTO schema_migrations (version) VALUES ('20100405170612');

INSERT INTO schema_migrations (version) VALUES ('20100405230549');

INSERT INTO schema_migrations (version) VALUES ('20100414122916');

INSERT INTO schema_migrations (version) VALUES ('20100416163000');

INSERT INTO schema_migrations (version) VALUES ('20100416163809');

INSERT INTO schema_migrations (version) VALUES ('20100416171751');

INSERT INTO schema_migrations (version) VALUES ('20100419213357');

INSERT INTO schema_migrations (version) VALUES ('20100427204314');

INSERT INTO schema_migrations (version) VALUES ('20100503063804');

INSERT INTO schema_migrations (version) VALUES ('20100503110037');

INSERT INTO schema_migrations (version) VALUES ('20100510213608');

INSERT INTO schema_migrations (version) VALUES ('20100510214253');

INSERT INTO schema_migrations (version) VALUES ('20100511162216');
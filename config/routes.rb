ActionController::Routing::Routes.draw do |map|
  map.resources :states

  map.resources :countries

  map.resources :message_templates

  map.new_cus 'new_cus',:controller=>'customers',:action=>'new_cus'
  map.api_post  'api/post',:controller=>'api',:action=>'post'
  map.signup 'signup', :controller => 'users', :action => 'new'
  map.logout 'logout', :controller => 'sessions', :action => 'destroy'
  map.login 'login', :controller => 'sessions', :action => 'new'
  map.customer_login 'customer_login', :controller => 'customer_sessions', :action => 'new'
  map.customer_logout 'customer_logout', :controller => 'customer_sessions', :action => 'destroy'
  map.investor_login 'investor_login', :controller => 'investor_sessions', :action => 'new'
  map.investor_logout 'investor_logout', :controller => 'investor_sessions', :action => 'destroy'
  map.accept_agreement 'loan_confirmation/accept_agreement', :controller => 'loan_confirmation', :action => 'accept_agreement'
  map.tila 'customers/tila', :controller => 'loan_confirmation', :action => 'show'
  map.connect '/mark_notification_as_read/:id', :controller => 'users', :action => 'mark_notification_as_read'
  map.connect 'loan_confirmation/:signature_token', :controller => 'loan_confirmation', :action => 'index'
  map.resources :admin_portfolios
  map.resources :message_categories
  map.resources :sessions
  map.resources :customer_sessions
  map.resources :investor_sessions
  map.resources :locations
  map.resources :high_risk_bank_branches
  map.resources :users
  map.resources :teams
  map.resources :documents
  map.resources :reminders
  map.resources :teams, :member => {
    :update_available_users => :post
  }
  
  map.search '/search', :controller => 'search', :action => 'results'
  map.resources :logs
  
  map.connect '/teams/getusers/:role', :controller => 'teams', :action => 'getusers'

  # Auto Session Timeout
  map.active '/active', :controller => 'sessions', :action => 'active'
  map.timeout '/timeout', :controller => 'sessions', :action => 'timeout'
  map.active '/active_investor', :controller => 'investor_sessions', :action => 'active_investor'
  map.timeout '/timeout_investor', :controller => 'investor_sessions', :action => 'timeout_investor'
  
  # Customers
  map.my_customers 'my_customers', :controller => 'customers', :action => 'my_customers'
  map.team_availability 'team_availability', :controller => 'users', :action => 'team_availability'
  map.update_available 'update_available', :controller => 'users', :action => 'update_available', :id => :id
  map.resources :customers, :member => { :complete_approval_process => :put, :update_validation_status => :post, :tila => :get, :add_comment => :post}

  # Loans
  map.loan_remark "loan/:id/loan_remark",:controller=>"loans",:action=>"loan_remark"
  map.add_comment_customer "loan/:id/add_comment_customer",:controller=>"loans",:action=>"add_comment_customer"
  map.employer_informmation "loan/employer_information/:id",:controller=>"loans",:action=>"employer_information"
  map.payment 'payment',:controller=>'loans',:action=>'payment'
  map.loan_tran_payments 'loan_tran_payments/:id', :controller => 'loans', :action => 'loan_tran_payments'
  map.loan_info_history 'loan_info_history/:id',:controller=>'loans',:action=>'loan_info_history'
  map.my_loans 'my_loans', :controller => 'loans', :action => 'my_loans'
  map.set_garnishment_status 'set_garnishment_status/:id', :controller => 'loans', :action => 'set_garnishment_status'
  map.payment_plans 'payment_plans', :controller => 'loans', :action => 'payment_plans'
  map.garnishment_payment_plans 'garnishment_payment_plans', :controller => 'loans', :action => 'garnishment_payment_plans'
  
  #map.set_aba_number 'set_bank_account_bank_aba_number/:id', :controller => 'loans', :action => 'set_bank_account_bank_aba_number'
  map.resources( :loans,
    :collection => {
      :garnishment_paying => :get,
      :garnishment_follow_up => :get
    },
    :member => {
      :complete_approval_process => :put,
      :update_validation_status => :post,
      :update_disclosure_status => :post,
      :tila => :get,
      :add_comment => :post,
      :edit_financial_data => :post,
      :set_loan_as_garnishment => :post
    }
  )
  
  # Lead Filters
  map.resources :lead_filters
  
  # Lead Providers
  map.resources :lead_providers
  
  # Factor Trust
  map.resources :factor_trust
  
  # Mail Templates
  map.resources :mail_templates

  # Member Area
  map.member_area_root 'member_area_root', :controller => 'member_area', :action => 'index'
  map.member_area_home 'member_area_home', :controller => 'member_area', :action => 'index'
  map.member_area_payments 'member_area_payments', :controller => 'member_area', :action => 'make_payment'
  map.member_area_scheduled_payments 'member_area_scheduled_payments', :controller => 'member_area', :action => 'scheduled_payments'
  map.member_area_extensions 'member_area_extensions', :controller => 'member_area', :action => 'extend_loan'
  map.member_area_new_loan 'member_area_new_loan', :controller => 'member_area', :action => 'new_loan'
  map.member_area_new_loan_blocked 'member_area_new_loan_blocked', :controller => 'member_area', :action => 'new_loan_blocked'
  map.member_area_agreement 'member_area_agreement', :controller => 'member_area', :action => 'tila'
  map.member_area_history 'member_area_history', :controller => 'member_area', :action => 'history'
  map.member_area_contact 'member_area_contact', :controller => 'member_area', :action => 'contact'
  map.member_area_credit_limit 'member_area_credit_limit', :controller => 'member_area', :action => 'credit_limit'
  map.member_area_tila 'member_area_tila', :controller => 'member_area', :action => 'tila'

  #Investor Area
  map.investor_area_root 'investor_area_root', :controller => 'investor_area', :action => 'index'
  map.investor_area_home 'investor_area_home', :controller => 'investor_area', :action => 'index'

  #Reports
  map.marketing 'marketing', :controller => 'reports', :action => 'marketing'
  map.portfolio 'portfolio', :controller => 'reports', :action => 'portfolio'
  map.financial 'financial', :controller => 'reports', :action => 'financial'
  map.performance 'performance', :controller => 'reports', :action => 'performance'
  map.performance_asper_selectdate 'performance_asper_selectdate', :controller => 'reports',:action=>'performance_asper_selectdate'
  map.investors 'investors', :controller => 'reports', :action => 'investors'
  map.portfolio_snapshot 'portfolio_snapshot', :controller => 'reports', :action => 'portfolio_snapshot'
  map.set_portfolio_trend 'set_portfolio_trend/:p', :controller => 'reports', :action => 'set_portfolio_trend'
  map.export_to_csv 'export_to_csv', :controller => 'reports', :action => 'export_to_csv'
  map.export_to_excel 'export_to_excel', :controller => 'reports', :action => 'export_to_excel'
  map.export_performance_data_to_excel 'export_performance_data_to_excel',:controller=>'reports',:action=>'export_performance_data_to_excel'
  map.export_to_pdf 'export_to_pdf', :controller=> 'reports', :action=> 'export_to_pdf'
  map.export_performance_data_to_pdf 'export_performance_data_to_pdf',:controller=>'reports',:action=>'export_performance_data_to_pdf'
  map.export_performance_csv 'export_performance_csv',:controller=>'reports',:action=>'export_performance_csv'
#  map.performance 'performance', :controller => 'reports', :action => 'show_report'
  map.reminders_report 'reminders_report', :controller => 'reports', :action => 'reminders'
  
  #Collections Reports
  map.collection_marketing 'collection_marketing', :controller => 'reports', :action => 'collection_marketing'
  map.collection_portfolio 'collection_portfolio', :controller => 'reports', :action => 'collection_portfolio'
  map.collection_financial 'collection_financial', :controller => 'reports', :action => 'collection_financial'
  map.collection_performance 'collection_performance', :controller => 'reports', :action => 'collection_performance'
  map.collection_investors 'collection_investors', :controller => 'reports', :action => 'collection_investors'
  
  #Garnishments Reports
  map.garnishments_marketing 'garnishments_marketing', :controller => 'reports', :action => 'garnishments_marketing'
  map.garnishments_portfolio 'garnishments_portfolio', :controller => 'reports', :action => 'garnishments_portfolio'
  map.garnishments_financial 'garnishments_financial', :controller => 'reports', :action => 'garnishments_financial'
  map.garnishments_performance 'garnishments_performance', :controller => 'reports', :action => 'garnishments_performance'
  map.garnishments_investors 'garnishments_investors', :controller => 'reports', :action => 'garnishments_investors'

  #Admin Dashboard Chart
  map.chart_asper_selectdate 'chart_asper_selectdate/:portfolio_id', :controller => 'dashboard',:action=>'chart_asper_selectdate'
  map.all_portfolio_chart '/chart_asper_selectdate', :controller => 'dashboard',:action=>'chart_asper_selectdate'


  # Root
  map.root :controller => 'dashboard'
  #map.resources :document
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
end

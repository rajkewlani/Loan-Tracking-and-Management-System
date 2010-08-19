namespace :send do

  desc 'Send Messages On Point-in-time Schedules'
  task :message => :environment do

    msg_templates = MessageTemplate.find(:all, :conditions => ["send_schedule_flag = ? and enabled = ?", MessageTemplate::POINT_IN_TIME,true])
    msg_templates.each do |msg_template|
      day_multiplier = msg_template.before_after.downcase == 'before' ? -1 : 1
      query = "#{msg_template.base_date} = ?"
      base_date = (Date.today + (msg_template.days * day_multiplier)).to_s(:db)
      conditions = [query,base_date]
      if msg_template.required_aasm_state
        conditions[0] += " and aasm_state = ?"
        conditions << msg_template.required_aasm_state
      end
      loans = Loan.find(:all,:conditions => conditions,:order=>"created_at", :limit => 3)
      if not loans.nil?
        loans.each do |loan|
          msg_template.deliver(loan)
        end
      end
    end
    puts "message sent"
  end
end
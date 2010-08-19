require File.dirname(__FILE__) + '/../test_helper'

class LeadFilterTest < ActionController::IntegrationTest

  context "When managing Lead Filters as an Administrator" do

    setup do
      @default_filter = Factory.create(:lead_filter)
    end

    should "be able to add a new filter" do
      visit lead_filters_path
      click_link "Create"
      fill_in "Filter Name", :with => "Test Filter"
      select "3 months", :from => "Minimum Months at Job"
      select "2 months", :from => "Minimum Months at Bank"
      fill_in "Minimum Age", :with => "21"
      check "lead_filter[allow_pay_frequency_biweekly]"
      check "lead_filter[allow_pay_frequency_monthly]"
      check "lead_filter[allow_pay_frequency_twice_per_month]"
      check "lead_filter[allow_payroll_type_direct_deposit]"
      click_button "Save"
      assert response.body.include?("Created new lead submission filter successfully!")
    end

    should "be able to edit an existing filter" do
      visit edit_lead_filter_path(@default_filter)
      fill_in "Filter Name", :with => "Updated Default"
      click_button "Save"
      assert response.body.include?("Updated lead submission filter successfully!")
      assert response.body.include?("Updated Default")
    end

  end

end

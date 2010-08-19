class RemindersController < ApplicationController
  include ActionView::Helpers::NumberHelper
  before_filter :login_required

  in_place_edit_for :reminder, :remind_on
  in_place_edit_for :reminder, :comment

  def index
    @reminders = Reminder.find(:all, :conditions => ["remind_on >= ?",Date.today])
  end

  def show
    @reminder = Reminder.find(params[:id])
  end

  def new
    @reminder = Reminder.new
  end

  def create
    begin
      reminder = Reminder.new(params[:reminder])
      reminder.user_id = session[:user_id]
      reminder.save!
    rescue Exception => e
      render :text => e.message
      return
    rescue => e
      render :text => e
      return
    end
    render :text => 'OK'
  end

  def edit
    @reminder = Reminder.find(params[:id])
  end

  def update
  end
  
  def destroy
    reminder = Reminder.find(params[:id])
    loan_id = reminder.loan.id
    reminder.destroy
    redirect_to loan_path(loan_id, :tab => 'comments')
  end

end

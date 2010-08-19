module InPlaceEditing
  def self.included(base)
    base.extend(ClassMethods)
  end
 
  # Example:
  #
  # # Controller
  # class BlogController < ApplicationController
  #   in_place_edit_for :post, :title
  # end
  #
  # # View
  # <%= in_place_editor_field :post, 'title' %>
  #
  module ClassMethods
    def in_place_edit_for(object, attribute, options = {})
      if options[:if] && options[:if].is_a?(Proc)
        return unless options[:if].call
      end
      define_method("set_#{object}_#{attribute}") do
        @item = object.to_s.camelize.constantize.find(params[:id])
        if ["phone", "currency"].include? options[:format]
          params[:value] = params[:value].scan(/(\d|\.)/).join
        end
        @item.update_attribute(attribute, params[:value])
        #begin
          @item.logs << Log.new(:message => "#{current_user.full_name} changed #{attribute.to_s} to #{params[:value].to_s}", :user => current_user)
        #rescue; end
        ret_string = @item.send(attribute).to_s
        if options[:format] == 'date'
          render :text => Date.parse(ret_string).strftime("%B %d, %Y")
        elsif options[:format] == 'phone' && !ret_string.blank?
          render :text => ret_string.using('(###) ###-####')
        elsif options[:format] == 'currency' && !ret_string.blank?
          render :text => ActionController::Base.helpers.number_to_currency(ret_string.to_f)
        elsif options[:format] == 'key_value'
          opts = Hash.new
          options[:values].each do |opt|
            spl = opt.split(":")
            if spl.length == 2
              opts[spl[1]] = spl[0]
            else
              opts[spl[0]] = spl[0]
            end
          end
          render :text => opts[ret_string].to_s
        else
          render :text => ret_string
        end
        
        #render :text => @item.send(attribute).to_s
      end
    end
  end
end

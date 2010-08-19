# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def production?
    ENV["RAILS_ENV"]=='production'
  end

  def form_for_using_SSL_in_prod(record_or_name_or_array, *args, &proc)
    options = args.extract_options!
    options [:url][:protocol], options [:url][:only_path] = 'https', false if production?
    args << options
    form_for record_or_name_or_array, *args, &proc
  end
  
  def boolean_to_english(val)
    if val == true
      "Yes"
    else
      "No"
    end
  end

  def complete_or_incomplete_icon(complete)
    "icons/icn_#{complete ? 'complete' : 'incomplete'}.gif"
  end
  
  def display_warning_tooltip(obj, col, val)
    img_id = "#{obj.to_s}-#{col.to_s}-yield"
    ret = <<-EOF
    <img src="/images/icons/tiny_yield.png" align="top" id="#{img_id}" class="tooltip yield" width="10" height="10" />
    <script type="text/javascript">
      $(document).ready(function() {
        $('##{img_id}').qtip({
           content: '#{h(val)}',
           show: 'mouseover',
           hide: 'mouseout',
           style: { name: 'red', tip: true }
        })
      })
    </script>
    EOF
    return ret
  end
  
  def default_tab_class(id)
    return 'default-tab' if @default_tab == id
  end
  
end

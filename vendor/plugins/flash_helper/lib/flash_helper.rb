module FlashHelper
  
  def display_flash(flash)
    ret = []
    flash.each do |name, msg|
      ret << build_flash_html(name, msg)
    end
    ret
  end
  
  def build_flash_html(name, msg)
    ret = <<-EOF
    <div class="notification #{name} png_bg">
    	<a href="#" class="close"><img src="/images/icons/cross_grey_small.png" title="Close this notification" alt="close" /></a>
    	<div>#{msg}</div>
    </div>
    EOF
    return ret
  end
  
end


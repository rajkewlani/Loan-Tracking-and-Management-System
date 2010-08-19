module FourOneOne

  MULTIPLE_RESULTS = 'div[@class="mr_top"]'
  LISTING_DETAIL = 'div[@class="listing_detail_top"]'
  LOCATION_ONLY = 'h1[@class="location_only"]'
  NOT_FOUND = 'h1#error_title'

  class << self
    def perform(phone_number)
      listings = []
      agent = Mechanize.new { |a| a.log = Logger.new("log/four_one_one.log") }
      agent.user_agent_alias = 'Mac Safari'
#      page = agent.get("http://www.411.com/reverse_phone")
#      search_form = page.forms.first
#      search_form["full_phone"] = phone_number
#      page = agent.submit(search_form)


      page = agent.get("http://www.411.com/search/ReversePhone?full_phone=#{phone_number}&localtime=survey")
      puts "page.class: #{page.class}"
      doc = page.parser
      puts "doc.class: #{doc.class}"

      # What kind of page is it?  (Single or Multiple results)
      search_strings = [MULTIPLE_RESULTS,LISTING_DETAIL,LOCATION_ONLY]
      search_strings.each do |sr|
        tag = doc.search(sr)
        unless tag.empty?
          puts "sr: #{sr}"
          case sr
          when MULTIPLE_RESULTS
            puts "MULTIPLE_RESULTS"
            doc.search('div[@class="result"]').each do |node|
              listing = FourOneOne::Listing.new
              listing.owner = node.search('p[@class="name"]/a').text
              link = 'http://www.411.com' + node.search('p[@class="name"]/a').attr('href')

              detail_page = agent.get(link)
              detail_doc = detail_page.parser
              addr = detail_doc.search('p[@class="address"]').text
              city_state_zip = addr.split("\n")[3]
              listing.zip = city_state_zip.split(',').last.split(' ').last

              address_info = node.search('ol[@class="result"]')
              street_address = address_info.search('li[@class="col_address"]').text.strip
              listing.address = street_address.split("\n")[1].strip
              city_and_state = address_info.search('li[@class="col_location"]').text
              listing.city = city_and_state.split(',')[0].strip
              listing.state = city_and_state.split(',')[1].strip
              company_and_title = address_info.search('li[@class="col_info"]').text.strip
              if company_and_title
                ascii = ''
                company_and_title.each_byte { |c| ascii << c unless c > 127 }
                company_and_title = ascii
                company_and_title.gsub!(/Job:/,'')
                company_and_title.strip if company_and_title
                parts = company_and_title.split(',')
                if company_and_title
                  listing.company = parts[0].strip if parts[0]
                  listing.title = parts[1].strip if parts[1]
                end
              end
              cell_available = node.search('div[@class="cell_email_phone"]/ul/li[@class="cell_available"]')
              landline_available = node.search('div[@class="cell_email_phone"]/ul/li[@class="landline_available"]')
              listing.line_type = 'cell phone' if cell_available
              listing.line_type = 'landline' if landline_available

              listings << listing
            end
          when LISTING_DETAIL
            puts "LISTING_DETAIL"
            listing = FourOneOne::Listing.new
            addr = doc.search('p[@class="address"]').text
            city_state_zip = addr.split("\n")[3]
            listing.zip = city_state_zip.split(',').last.split(' ').last
            listings << listing
          when LOCATION_ONLY
            listing = FourOneOne::Listing.new
            puts "LOCATION_ONLY"
            paragraph = doc.search('div[@id="location_only_left"]/p')
            puts "paragraph.size: #{paragraph.size} paragraph.text: #{paragraph.text}"
            paragraph.search('strong').each do |strong|
              puts "strong: #{strong.text}"
              if strong.text.index(',')
                listing.city = strong.text.split(',')[0]
                listing.state = strong.text.split(',')[1]
              else
                listing.line_type = strong.text
              end
            end
            listings << listing
          when NOT_FOUND
            puts "NOT_FOUND"
          end
        end
      end


      return listings
    end
  end

  class Listing
    attr_accessor :owner, :title, :company, :address, :city, :state, :zip, :phone, :line_type, :provider
  end
  
end
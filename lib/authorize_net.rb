module AuthorizeNet
    
  def submit_credit_card_transaction(amount,card_num,exp_date,card_code,name,address,zip,description)
    hash = Hash.new
    hash['x_login'] = 'LOGIN ID GOES HERE'
    hash['x_tran_key'] = 'TRANSACTION KEY GOES HERE'
    hash['x_version'] = '3.1'
    hash['x_delim_data'] = 'true'
    hash['x_relay_response'] = 'false'
    hash['x_amount'] = sprintf("%0.02f",amount)
    hash['x_card_num'] = card_num
    hash['x_exp_date'] = exp_date
    hash['x_card_code'] = card_code
    hash['x_address'] = address
    hash['x_zip'] = zip
    hash['x_description'] = description
    if RAILS_ENV=='production'
        hash['x_duplicate_window'] = 60
    else
        hash['x_test_request'] = 'true'
    end
    
    # Build the POST data string
    post_string = ''
    hash.each { |key, value|
        post_string = post_string + '&' if post_string.length > 0
        post_string += key + '=' + value.to_s
    }
    
    http = Net::HTTP.new('secure.authorize.net',443)
    http.use_ssl = true
    path = '/gateway/transact.dll'
    response = http.post(path,post_string)
    response
  end
end

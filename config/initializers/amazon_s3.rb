AMAZON_S3_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/amazon_s3.yml")[RAILS_ENV].symbolize_keys

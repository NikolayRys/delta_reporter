require 'dotenv/load'
require 'erb'
require 'yaml'
require 'httparty'
require 'timerizer'

def load_config
  yaml_content = File.read('config.yml')
  YAML.load(ERB.new(yaml_content).result(binding))
end

def get_ratios_for_day(date, currencies)
  date_url = "#{CONFIG['fixer_proxy_domain']}:#{CONFIG['fixer_proxy_port']}/#{date}"

  response = HTTParty.get(date_url, query: {symbols: currencies.join(',')})
  response.fetch('rates', {})
end

def create_report_file(today, report_hash, format)
  if CONFIG['formats'].include?(format)
    require_relative "formatters/#{format}"
    file_name = "reports/#{today}.#{format}"
    File.write(file_name, send("to_#{format}", report_hash))
    file_name
  end
end

CONFIG = load_config

currencies = CONFIG['currencies']
today = Date.today.to_s

rates_today = get_ratios_for_day(today, currencies)
rates_yesterday = get_ratios_for_day(1.day.ago.to_date, currencies)
rates_week_ago = get_ratios_for_day(7.days.ago.to_date, currencies)
rates_month_ago = get_ratios_for_day(1.month.ago.to_date, currencies)
rates_year_ago = get_ratios_for_day(1.year.ago.to_date, currencies)

report_hash = currencies.each_with_object({}) do |symbol, result|
  result[symbol] = {
    current: rates_today[symbol],
    since_yesterday: (rates_yesterday[symbol] - rates_today[symbol]).round(6),
    since_week_ago: (rates_week_ago[symbol] - rates_today[symbol]).round(6),
    since_month_ago: (rates_month_ago[symbol] - rates_today[symbol]).round(6),
    since_year_ago: (rates_year_ago[symbol] - rates_today[symbol]).round(6)
  }
end


created_files = []
created_files << create_report_file(today, report_hash, 'json')
created_files << create_report_file(today, report_hash, 'csv')
created_files << create_report_file(today, report_hash, 'xml')
created_files << create_report_file(today, report_hash, 'html')


if CONFIG['environment'] == 'production'
  puts '** UPLOADING TO AWS S3 **'
  require 'aws-sdk-s3'

  created_files.compact.each do |file_name|
    puts file_name
  end

  s3 = Aws::S3::Resource.new(region: 'us-west-3')

end




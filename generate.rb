require 'dotenv/load'
require 'yaml'
require 'httparty'
require 'timerizer'
require 'aws-sdk-s3'

def get_ratios_for_day(date, currencies)
  date_url = "#{CONFIG['fixer_proxy_domain']}:#{CONFIG['fixer_proxy_port']}/#{date}"

  response = HTTParty.get(date_url, query: {symbols: currencies.join(',')})
  response.fetch('rates', {})
end

def create_report_file(today, report_hash, format)
  if CONFIG['formats'].include?(format)
    require_relative "formatters/#{format}"
    file_path = "reports/#{today}.#{format}"
    File.write(file_path, send("to_#{format}", report_hash))
    puts "Generated #{file_path}"
    file_path
  end
end

def get_delta(symbol, start_rates, end_rates)
  (start_rates[symbol] - end_rates[symbol]).round(6)
end

CONFIG = YAML.load(File.read('config.yml'))

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
    since_yesterday: get_delta(symbol, rates_yesterday, rates_today),
    since_week_ago: get_delta(symbol, rates_week_ago, rates_today),
    since_month_ago: get_delta(symbol, rates_month_ago, rates_today),
    since_year_ago: get_delta(symbol, rates_year_ago, rates_today),
  }
end

created_files = []
created_files << create_report_file(today, report_hash, 'json')
created_files << create_report_file(today, report_hash, 'csv')
created_files << create_report_file(today, report_hash, 'xml')
created_files << create_report_file(today, report_hash, 'html')


if CONFIG['environment'] == 'production'
  s3 = Aws::S3::Resource.new(region: 'eu-west-3')

  created_files.compact.each do |file_path|
    obj = s3.bucket('freska').object(File.basename(file_path))
    obj.upload_file(file_path)
    puts "Uploaded to AWS: #{file_path}"
  end
end




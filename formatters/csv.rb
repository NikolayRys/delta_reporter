require 'csv'

def to_csv(report_hash)
  CSV.generate do |csv|
  csv << %w[symbol current since_yesterday since_week_ago since_month_ago since_year_ago]
    report_hash.each do |symbol, values_hash|
      csv << [
        symbol,
        values_hash[:current],
        values_hash[:since_yesterday],
        values_hash[:since_week_ago],
        values_hash[:since_month_ago],
        values_hash[:since_year_ago],
      ]
    end
  end
end

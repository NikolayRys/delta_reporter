require 'builder'

def to_xml(report_hash)
  xml = Builder::XmlMarkup.new(indent: 2)
  xml.instruct!(:xml, encoding: 'ASCII')
  xml.root do |root|
    report_hash.each do |symbol, values_hash|
      root.__send__(symbol) do |tag|
        tag.current(values_hash[:current])
        tag.since_yesterday(values_hash[:since_yesterday])
        tag.since_week_ago(values_hash[:since_week_ago])
        tag.since_month_ago(values_hash[:since_month_ago])
        tag.since_year_ago(values_hash[:since_year_ago])
      end
    end
  end

  xml.target!
end

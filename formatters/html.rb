require 'builder'

def to_html(report_hash)
  html = Builder::XmlMarkup.new(indent: 2)
  html.instruct!(:html, encoding: 'ASCII')
  html.head do
    html.title('Report for EUR')
  end
  html.body do
    report_hash.each do |symbol, values_hash|
      html.h2(symbol)
      html.table do
        html.tr do
          html.th('Current')
          html.th(values_hash[:current])
        end
        html.tr do
          html.th('Since yesterday')
          html.th(values_hash[:since_yesterday])
        end
        html.tr do
          html.th('Since week ago')
          html.th(values_hash[:since_week_ago])
        end
        html.tr do
          html.th('Since month ago')
          html.th(values_hash[:since_month_ago])
        end
        html.tr do
          html.th('Since year ago')
          html.th(values_hash[:since_year_ago])
        end
      end
    end
  end
  html.target!
end

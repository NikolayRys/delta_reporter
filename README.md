# Delta reporter
Test task for Freska.
Microservice that produces reports on currency changes through fixer_proxy service


## Setup
* Set up and start up the [fixer_proxy](https://github.com/NikolayRys/fixer_proxy) service
* `git clone git@github.com:NikolayRys/delta_reporter.git && cd delta_reporter`
* Put working AWS key id to `AWS_KEY_ID` environment variable
* Put corresponding secret key to `AWS_SECRET_KEY` var
* Application expects S3 bucket named "freska" to be present
* Alternatively, provide a `.env` file with both values
* `bundle install`
* Check that `config.yml` contains all required currencies, possibilities are documented in fixer_proxy.
* Check if environment is correct. Possible values are `development` and `production`
* Choose output format. `csv`, `xls`, `html` and `json` values are recognized

## Usage
`ruby generate.rb`
It will generate report for the current calendar_date.
Depending on the enabled environment, it will be stored


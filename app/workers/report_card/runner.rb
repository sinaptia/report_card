require 'csv'

module ReportCard
  class Runner
    include Sidekiq::Worker

    def perform(params, recipient_email)
      report = ReportCard::Report.find(params['report_name']).new(params)

      tempfile = Tempfile.new(['report_card', '.csv'])
      csv = CSV.open(tempfile, 'wb')
      report.to_csv(csv)
      csv.close

      uploader = ReportCard::Uploader.new
      uploader.store!(csv)

      ReportCard::Mailer.report(uploader.url, recipient_email).deliver
    end
  end
end

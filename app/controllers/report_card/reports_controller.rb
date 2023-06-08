module ReportCard
  class ReportsController < ReportCardController
    def index
      @reports = ReportCard::Report.all
    end

    def create
      if ReportCard::Report.exists?(params[:report_name])

        unless params.key?(:email_options)
          params[:email_options] = {}
          params[:email_options][:recipient_email] = instance_eval(&ReportCard.recipient_email)
        end

        flash_success = params[:flash_success] || instance_eval(&ReportCard.flash_success)
        ReportCard::Runner.perform_async(params.to_unsafe_h)
        redirect_back fallback_location: root_path, flash: { success: flash_success }
      else
        redirect_back fallback_location: root_path, flash: { error: 'Could not find report' }
      end
    end
  end
end

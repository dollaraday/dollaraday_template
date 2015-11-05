class Admin::NewslettersController < Admin::BaseController
  respond_to :html

  before_filter :find_newsletter, only: [:show, :preview, :donor_generated, :subscriber_generated, :send_preview]

  def index
    @newsletters = Newsletter.all
  end

  def show
  end

  # generated newsletter for iframe
  def donor_generated
    newsletter = NewsletterMailer.batched_newsletter_for(@newsletter.id, 'donor')
    subscriber = Donor.new(subscriber: Subscriber.new(name: "Fake Donor", email: "*@*.com"))

    render text: newsletter_preview(newsletter, subscriber, 'donor')
  end

  # generated newsletter for iframe
  def subscriber_generated
    newsletter = NewsletterMailer.batched_newsletter_for(@newsletter.id, 'subscriber')
    subscriber = Subscriber.new(name: "Fake Subscriber", email: "*@*.com")

    render text: newsletter_preview(newsletter, subscriber, 'subscriber')
  end

  def preview
    params[:type] ||= 'donor'
  end

  def send_preview
    params[:type] ||= 'donor'
    emails = params[:emails].split(',').map(&:strip)

    begin
      recipients = {}
      emails.each { |e| recipients[e] = {"name" => e.split('@')[0]} }

      if params[:type].in?(%w(donor subscriber))
        NewsletterMailer.batched_daily(params[:type], @newsletter.id, recipients).deliver
        flash[:notice] = "Preview sent to: #{emails}"
      end
    rescue => e
      flash[:error] = e.to_s
    end
    redirect_to preview_admin_newsletter_url(@newsletter)
  end

  private

  def find_newsletter
    @newsletter = Newsletter.find(params[:id])
    @nonprofit = @newsletter.nonprofit
  end

  def newsletter_params
    params.require(:newsletter).permit(:nonprofit_id)
  end

  def newsletter_preview(mailer, subscriber, type)
    newsletter_preview = "Subject: #{mailer.subject}<br>"

    newsletter_preview << "Body:<br><br><br> #{mailer.body}"

    newsletter_preview.gsub!(/%recipient.name%/, current_user.name)

    newsletter_preview.html_safe
  end

end


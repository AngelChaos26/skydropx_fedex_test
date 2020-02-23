require 'open-uri'
# +ApplicationMailer+ definition
class ApplicationMailer < ActionMailer::Base
  # Mailer default settings
  default from: ENV['SES_FROM']
  layout 'mailer'
  # set URLS
  before_action :set_external_urls!
  before_action :attach_support!, only: %i[reset_password_instructions
                                           admin_behavior_cancel
                                           admin_behavior_warning
                                           plan_no_balance plan_with_balance
                                           user_behavior_cancel]
  before_action :attach_social_tags!, except: %i[extension_delete
                                                 reset_password_instructions
                                                 admin_behavior_cancel
                                                 admin_behavior_warning
                                                 plan_no_balance
                                                 plan_with_balance
                                                 user_behavior_cancel]
  before_action :attach_badges!, only: %i[company_new extension_delete
                                          email_support_code]

  # Delivers a new HTML email template for the given parameters
  # @param company - Company instance
  # @param company_phone - CompanyPhone instance
  # @return nil
  def company_new(company, company_phone)
    @company = company
    @company_phone = company_phone
    @trial_duration = Company::TrialLimits::DURATION
    @play_store = ENV['PLAY_STORE_URL']
    @app_store = ENV['APP_STORE_URL']
    mail(
      to: company_phone.extensions.admin.first.email,
      subject: '¡Bienvenido a GurúComm!'
    )
  end

  # Delivers a new HTML email template for the given parameters
  # @param extension - Extension instance
  # @return nil
  def extension_delete(extension)
    @extension = extension
    @company = @extension.company_phone.company
    mail(
      to: extension.email,
      subject: "#{@company.name} ha eliminado un conmutador."
    )
  end

  # Delivers a new HTML email template for the given parameters
  # @param extension [Extension] - Extension instance
  # @return nil
  def extension_new_or_updated(extension)
    @extension = extension
    @company_phone = @extension.company_phone
    @company = @company_phone.company
    mail(
      to: extension.email,
      subject: "#{@company.name} tiene una nuevo conmutador."
    )
  end

  # Delivers a new HTML email template for the given parameters
  # @param payment [Payment] - Payment instance
  # @param payable [Payable] - Payable polymorphic relation
  # @param company_phone [CompanyPhone] - CompanyPhone instance
  # @return nil
  def payment_new(payment, payable, company_phone)
    @payment = payment
    @payable = payable
    @company_phone = company_phone
    @company = Company.find_by!(
      id: company_phone[:company_id]
    )
    emails = company_phone.extensions.admin
    mail(
      to: emails.map(&:email),
      subject: '¡En GurúComm hemos recibido tu pago!'
    )
  end

  # Delivers a new HTML email template for the given parameters
  # @param payment_subscription - PaymentSubscription instance
  # @param company_phone - CompanyPhone instance
  # @return nil
  def payment_subscription_canceled(payment_subscription, company_phone)
    attachments.inline['consult.png'] = email_cdn_file '/img/consult.png'
    @plan = Plan.find_by!(
      id: payment_subscription[:plan_id]
    )
    @company = Company.find_by!(
      id: company_phone[:company_id]
    )
    @company_phone = company_phone
    emails = payment_subscription.company_phone.extensions.admin
    mail(
      to: emails.map(&:email),
      subject: '¡Tu subscripción a GurúComm se ha cancelado!'
    )
  end

  # Delivers a new HTML email template for the given parameters
  # @param company - Company instance
  # @param company_phone - CompanyPhone instance
  # @return nil
  def plan_no_balance(company, company_phone)
    @company = company
    @company_phone = company_phone
    mail(
      to: company_phone.extensions.admin.first.email,
      subject: '¡Tu plan en GurúComm se ha reactivado!'
    )
  end

  # Delivers a new HTML email template for the given parameters
  # @param company - Company instance
  # @param company_phone - CompanyPhone instance
  # @return nil
  def plan_with_balance(company, company_phone)
    @company = company
    @company_phone = company_phone
    mail(
      to: company_phone.extensions.admin.first.email,
      subject: '¡En GurúComm agradecemos tu recarga!'
    )
  end

  # Delivers a new HTML email template for the given parameters
  # @param voicemail - Voicemail
  # @param extension - Extension
  # @return nil
  def voicemail_new(voicemail, extension)
    attachments.inline['voicemail.png'] = email_cdn_file '/img/voicemail.png'
    @voicemail = voicemail
    @extension = extension
    @company_phone = @extension.company_phone
    @company = @company_phone.company
    attachments['voicemail.wav'] = read_url_file voicemail.audiofile
    mail(
      to: extension.email,
      subject: '¡En GurúComm, tienes un nuevo mensaje de voz!'
    )
  end

  # Delivers a new HTML email template for the given parameters.
  # @param resource - Devise resource (User)
  # @param token - Devise password recovery token
  # @param options - Hash with additional devise options
  # @return nil
  def reset_password_instructions(resource, token, _options)
    @resource = resource
    @token = token
    mail(
      to: resource.email,
      subject: ['¿Solicitaste un cambio de contraseña en tus servicios de ',
                'GurúComm?'].join('')
    )
  end

  # Delivers a new HTML email template for the given parameters
  # @param minute_plan - MinutePlan instance
  # @return nil
  def minute_plan_new(minute_plan)
    attachments.inline['money.png'] = email_cdn_file '/img/money.png'
    @minute_plan = minute_plan
    @company_phone = minute_plan.payment_subscription.company_phone
    @company = @company_phone.company
    mail(
      to: @company_phone.extensions.admin.first.email,
      subject: '¡Tu plan de minutos con GurúComm está activado!'
    )
  end

  # Delivers a new HTML email template for the given parameters
  # @param minute_plan - MinutePlan instance
  # @return nil
  def minute_plan_percentage_reminder(minute_plan)
    attachments.inline['saldo.png'] = email_cdn_file '/img/saldo.png'
    @minute_plan = minute_plan
    @minute_plan = minute_plan
    @company_phone = minute_plan.payment_subscription.company_phone
    @company = @company_phone.company
    mail(
      to: @company_phone.extensions.admin.first.email,
      subject: '¡Tu plan GurúComm se está terminando!'
    )
  end

  # Delivers a new HTML email template for the given parameters
  # @param minute_plan - MinutePlan instance
  # @return nil
  def minute_plan_empty(minute_plan)
    attachments.inline['saldo.png'] = email_cdn_file '/img/saldo.png'
    @minute_plan = minute_plan
    @company_phone = minute_plan.payment_subscription.company_phone
    @company = @company_phone.company
    mail(
      to: @company_phone.extensions.admin.first.email,
      subject: '¡Tu plan de minutos GurúComm se terminó! :('
    )
  end

  # Delivers a new HTML email template for the given parameters
  # @param [string] email - Receipient email
  # @param [CompanyPhone] company_phone - CompanyPhone instance
  # @return nil
  def admin_behavior_warning(email, company_phone, notification)
    @company_phone = company_phone
    @company = @company_phone.company
    @notification = notification
    mail(
      to: email,
      subject: 'GurúComm | Una línea esta cerca del límite de uso'
    )
  end

  # Delivers a new HTML email template for the given parameters
  # @param [string] email - Receipient email
  # @param [CompanyPhone] company_phone - CompanyPhone instance
  # @return nil
  def admin_behavior_cancel(email, company_phone, notification)
    @company_phone = company_phone
    @company = @company_phone.company
    @notification = notification
    mail(
      to: email,
      subject: 'GurúComm | Una línea fue cancelada por rebasar el límite de uso'
    )
  end

  # Delivers a new HTML email template for the given parameters
  # @param [string] email - Receipient email
  # @param [CompanyPhone] company_phone - CompanyPhone instance
  # @return nil
  def user_behavior_cancel(email, company_phone, notification)
    @company_phone = company_phone
    @company = @company_phone.company
    @notification = notification
    mail(
      to: email,
      subject: 'GurúComm | Tu línea fue cancelada por rebasar el límite de uso'
    )
  end

  # Delivers a new HTML email template for the given parameters
  # @param call - Call instance
  # @return nil
  def sentiment_too_low(call)
    @call = call
    @company_phone = call.company_phone
    @company = @company_phone.company
    attachments['call.wav'] = read_url_file call.audiofile
    mail(
      to: @company_phone.extensions.admin.first.email,
      subject: 'GurúComm | Llamada negativa'
    )
  end

  # Delivers a new HTML email template for the given parameters
  # @param [CompanyPhone] company_phone - CompanyPhone instance
  # @return nil
  def trial_ended(company_phone)
    attachments.inline['consult.png'] = email_cdn_file('/img/consult.png')
    @company_phone = company_phone
    @company = @company_phone.company
    @pay_url = "#{@landing_url}/pago?api_key=#{@company.api_key}"
    mail(
      to: @company_phone.extensions.admin.first.email,
      subject: 'GurúComm | Tu periodo de prueba ha finalizado'
    )
  end

  # Delivers a new HTML email template for the given parameters
  # @param [CompanyPhone] company_phone - CompanyPhone instance
  # @return nil
  def trial_warning(company_phone)
    @company_phone = company_phone
    @company = @company_phone.company
    @pay_url = "#{@landing_url}/pago?api_key=#{@company.api_key}"
    mail(
      to: @company_phone.extensions.admin.first.email,
      subject: 'GurúComm | Te queda un día de tu periodo de prueba'
    )
  end

  # Delivers a new HTML email template for the given parameters
  # @param [CompanyPhone] company_phone - CompanyPhone instance
  # @return nil
  def trial_early(company_phone)
    @company_phone = company_phone
    @company = @company_phone.company
    @trial_discount = ENV['TRIAL_EARLY_BUY_DISCOUNT']
    @pay_url = "#{@landing_url}/pago?api_key=#{@company.api_key}"
    @discount_limit =
      @company.trial_ends_at.localtime.strftime('%d/%m/%Y a las %H:%M')
    mail(
      to: @company_phone.extensions.admin.first.email,
      subject: 'GurúComm | Nos da gusto saber que estás usando GurúComm'
    )
  end

  # Delivers a new HTML email template for the given parameters
  # @param extension [Extension] - Extension instance
  # @return nil
  def email_support_code(extension)
    @extension = extension
    @company_phone = @extension.company_phone
    @company = @company_phone.company
    mail(
      to: extension.email,
      subject: 'GurúComm | Código de soporte'
    )
  end

  # Delivers a new HTML email template as a reminder for active current
  # balance remaining 5 days before expiry date
  # @param [CompanyPhone] company_phone
  # @param [Float] Current balance remaining
  # @return [nil]
  def balance_reminder(company_phone, total_current_balance)
    env_days_parameter = 'REMAINING_DAYS_TO_EXPIRE_MINUTE_PLANS'
    days_before_expire_minute_plan = ENV[env_days_parameter].to_i
    @remaining_balance = total_current_balance
    @company_phone = company_phone
    @company = @company_phone.company
    @days_before_expire = days_before_expire_minute_plan
    mail(
      to: @company_phone.extensions.admin.first.email,
      subject: 'GurúComm | Recordatorio no pierdas tu saldo'
    )
  end

  private

  # sets the appropriate external urls for +landing_url+, +dashboard_url+
  # and inline attachments to be rendered as part of the given HTML template
  # This method should be called as part of a +before_action+ filter call.
  # @return nil
  # @private
  def set_external_urls!
    @landing_url = ENV['LANDING_URL']
    @dashboard_url = ENV['DASHBOARD_URL']
    @facebook_url = ENV['FACEBOOK_URL']
    @twitter_url = ENV['TWITTER_URL']
    @desk_url = ENV['DESK_URL']
    @linkedin_url = ENV['DESK_URL']
    @telephone_support = ENV['TELEPHONE_SUPPORT']
    @email_support = ENV['EMAIL_SUPPORT']
    attachments.inline['logo.png'] = email_cdn_file '/img/main-logo.png'
    # Footer
    attachments.inline['corazon.png'] = email_cdn_file '/img/corazon.png'
    attachments.inline['fb.png'] = email_cdn_file '/img/fb.png'
    attachments.inline['tw.png'] = email_cdn_file '/img/tw.png'
    attachments.inline['linkedin.png'] = email_cdn_file '/img/linkedin.png'
  end

  # adds social media icons to the emails that use them
  # This method should be called as part of a +before_action+ filter call on
  # company_new and trial_warning methods
  # @return nil
  # @private
  def attach_social_tags!
    attachments.inline['facebook.png'] = email_cdn_file '/img/facebook.png'
    attachments.inline['twitter.png'] = email_cdn_file '/img/twitter.png'
    attachments.inline['chat.png'] = email_cdn_file '/img/chat.png'
  end

  # adds support phone & mail icons to the emails that use them
  # This method should be called as part of a +before_action+ filter call on
  # trial_early payment_new payment_subscription_canceled minute_plan_new
  # minute_plan_empty minute_plan_percentage_reminder methods
  # @return nil
  # @private
  def attach_support!
    attachments.inline['phone.png'] = email_cdn_file '/img/phone.png'
    attachments.inline['voicemail.png'] = email_cdn_file '/img/voicemail.png'
  end

  # adds iOS and Android badges to the emails that use them
  # This method should be called as part of a +before_action+ filter call on
  # company_new, extension_delete and extension_new_or_updated methods
  # @return nil
  # @private
  def attach_badges!
    attachments.inline['play-store.png'] = email_cdn_file '/img/play-store.png'
    attachments.inline['app-store.png'] = email_cdn_file '/img/app-store.png'
  end

  # reads and returns the file at ENV['EMAIL_CDN_URL'] + path
  # @param path [string] - file path
  # @return File
  # @private
  def email_cdn_file(path)
    read_url_file ENV['EMAIL_CDN_URL'] + path
  end

  # reads and returns the file at the given url
  # @param url [string] - url
  # @return File
  # @private
  def read_url_file(url)
    uri = URI.parse url
    uri.read
  end
end

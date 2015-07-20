require "application_responder"

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html

  include BootstrapFlashHelper
  include Pundit
  skip_around_filter :set_locale_from_url
  around_action :handle_customer

  respond_to :html, :json

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception
  protect_from_forgery with: :null_session

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :check_for_***REMOVED***
  before_action :check_for_current_role

  has_scope :q do |controller, scope, value|
    scope.search(value).limit(10)
  end

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def page
    params[:page] || 1
  end

  def per
    params[:per] || 10
  end

  def policy(record)
    begin
      Pundit::PolicyFinder.new(record).policy!.new(current_user, record)
    rescue
      ApplicationPolicy.new(current_user, record)
    end
  end
  helper_method :policy

  def handle_customer(&block)
    current_entity.using_connection(&block)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_in) do |u|
      u.permit(:credentials, :password, :remember_me)
    end

    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:email, :first_name, :last_name, :login, :phone, :cpf, :current_password, :authorize_email_and_sms)
    end

    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:email, :password, :password_confirmation)
    end
  end

  def check_for_***REMOVED***
    return unless current_user

    if syncronization = current_user.syncronizations.completed_unnotified
      flash.now[:notice] = t("ieducar_api_syncronization.completed")
      syncronization.notified!
    elsif syncronization = current_user.syncronizations.last_error
      flash.now[:alert] = t("ieducar_api_syncronization.error", error: syncronization.error_message)
      syncronization.notified!
    end
  end

  def check_for_current_role
    return unless current_user
    return if current_user.admin?

    if current_user.role.blank? && controller_name != "current_role"
      redirect_to current_roles_path
    end
  end

  def current_entity_configuration
    @current_entity_configuration ||= EntityConfiguration.first
  end
  helper_method :current_entity_configuration

  def current_entity
    @current_entity ||= Entity.find_by(domain: request.host)
    Entity.current = @current_entity
  end
  helper_method :current_entity

  def current_configuration
    @configuration ||= IeducarApiConfiguration.current
  end
  helper_method :current_configuration

  def current_notification
    @configuration ||= Notification.current
  end
  helper_method :current_notification

  def api
    @api ||= IeducarApi::StudentRegistrations.new(current_configuration.to_api)
  end

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore

    flash[:error] = t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default
    redirect_to(request.referrer || root_path)
  end

  def current_teacher
    current_user.try(:teacher)
  end
  helper_method :current_teacher

  def current_school_calendar
    SchoolCalendar.find_by(year: Date.today.year)
  end

  def current_test_setting
    TestSetting.find_by(year: Date.today.year)
  end

  def require_current_teacher
    unless current_teacher
      flash[:alert] = t('errors.general.require_current_teacher')
      redirect_to root_path
    end
  end

  def require_current_school_calendar
    unless current_school_calendar
      flash[:alert] = t('errors.general.require_current_school_calendar')
      redirect_to root_path
    end
  end

  def require_current_test_setting
    unless current_test_setting
      flash[:alert] = t('errors.general.require_current_test_setting')
      redirect_to root_path
    end
  end
end

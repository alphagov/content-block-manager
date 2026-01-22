module ContentBlockManager::ControllerMethods
  extend ActiveSupport::Concern

  included do
    include GDS::SSO::ControllerMethods

    layout "design_system"

    protect_from_forgery with: :exception, prepend: true

    prepend_before_action :authenticate_user!
    before_action :set_current_user
    before_action :set_authenticated_user_header

    helper_method :product_name
    helper_method :root_path

    helper :application, :header
  end

private

  def set_authenticated_user_header
    if current_user && GdsApi::GovukHeaders.headers[:x_govuk_authenticated_user].nil?
      GdsApi::GovukHeaders.set_header(:x_govuk_authenticated_user, current_user.uid)
    end
  end

  def set_current_user
    # current_user is only available within the controller whereas
    # Current.user is available globally for the duration of the
    # user's HTTP request (e.g. within models and service objects)
    Current.user = current_user
  end

  def product_name
    "Content Block Manager"
  end

  def root_path(args = {})
    Rails.application.routes.url_helpers.root_path(args)
  end
end

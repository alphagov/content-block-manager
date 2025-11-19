module FactCheck
  class ApplicationController < ActionController::Base
    include GDS::SSO::ControllerMethods

    prepend_before_action :authenticate_user!

    def product_name
      "Content Block Manager"
    end
    helper_method :product_name
  end
end

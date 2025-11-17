module FactCheck
  class ApplicationController < ActionController::Base
    def product_name
      "Content Block Manager"
    end
    helper_method :product_name
  end
end

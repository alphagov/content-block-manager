class ApplicationController < ActionController::Base
  include ContentBlockManager::ControllerMethods
  add_flash_types :success
end

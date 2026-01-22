module BlockPreview
  class ApplicationController < ActionController::Base
    include ContentBlockManager::ControllerMethods
  end
end

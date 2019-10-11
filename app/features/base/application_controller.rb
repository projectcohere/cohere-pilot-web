class ApplicationController < ActionController::Base
  include Clearance::Controller
  include Authentication
end

module Agent
  class AdminController < ApplicationController
    include Policy::Context::Shared
  end
end

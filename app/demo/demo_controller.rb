class DemoController < ApplicationController
  include DemoHelper

  # -- view helpers --
  helper(Cases::BaseHelper)
end

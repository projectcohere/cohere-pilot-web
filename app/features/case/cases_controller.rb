class Case
  class CasesController < ApplicationController
    def index
      @cases = Case::Repo.new.find_incomplete
    end
  end
end

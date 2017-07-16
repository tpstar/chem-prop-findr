class Api::ChemicalsController < ApplicationController
  def index
    @chemicals = Chemical.all
    render json: @chemicals
  end
end

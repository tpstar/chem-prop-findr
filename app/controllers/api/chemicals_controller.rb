class Api::ChemicalsController < ApplicationController

  def index
    chemicals = Chemical.all
    render json: chemicals, status: 201
  end

  def search
    chemical = Chemical.find_by(:name => params[:qchemname].capitalize)

    if chemical # check if the chemical is already in the database record
      render json: chemical

    else        # if is not in the record scrape from Aldrich website
      chemical = Chemical.new # create an instance of Chemical
      chemical.scrape(params[:qchemname]) # and scrape from Aldrich website

      if chemical.name # check if the chemical exists in Aldrich website
        exist_by_other_name(chemical) # check if the chemical exists in the record by other names
        # for example methyliodide and iodomethane are the same compound, but once it is recorded as Iodomethane
        # using search term as "methyliodide" will keep generate a new record
      else        # if it cannot be found in Aldrich website
        render json: {error: "Could not find the chemical!", status: 404}, status: 404
      end

    end
  end

  def exist_by_other_name(chemical)
    existing_chemical = Chemical.find_by(:name => chemical.name)
    # if it exists by other name
    if existing_chemical
      render json: existing_chemical
    # if it does not exist in the record by other name
    else
      chemical.save
      render json: chemical
    end
  end

  private

  def chemical_params
    params.require(:chemical).permit(:name, :formula, :fw, :density, :mp, :bp)
  end

end

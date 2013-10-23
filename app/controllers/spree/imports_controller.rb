class Spree::ImportsController < ApplicationController
  include Spree::ImportsHelper

  def create
    targets  = params[:targets]
    importer = SpreeImporter::Base.new

    importer.read params[:import]

    import_options    importer, targets[:options]
    import_properties importer, targets[:properties]
    import_prototypes importer, targets[:prototypes]
    import_products   importer, targets[:products]

    render json: true
  end

end

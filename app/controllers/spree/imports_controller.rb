class Spree::ImportsController < ApplicationController
  include Spree::ImportsHelper

  def create
    import = Spree::Import.new import_params

    import.save!
    import.run!
    render json: true
  end

  protected
  def import_params
    params.require(:import).permit :import_source_file_id, :target, arguments: [ ]
  end
end

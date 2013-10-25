class Spree::Admin::ImportSourceFilesController < Spree::Admin::BaseController
  def create
    params.require :import_source_file
    data        = params[:import_source_file][:data].read
    source_file = Spree::ImportSourceFile.new data: data, mime: "text/csv"

    if source_file.save
      if params[:import]
        source_file.import!
      end
      render json: true
    else
      render json: source_file.errors, status: :unprocessable_entity
    end
  end

  def update
    source_file = Spree::ImportSourceFile.find params[:id]
    source_file.import!
    render json: true
  end

  def index
    @import_source_file = Spree::ImportSourceFile.new
  end
end

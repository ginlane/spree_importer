class Spree::Admin::ImportSourceFilesController < Spree::Admin::ResourceController
  def new
    @import_source_file = Spree::ImportSourceFile.new
  end

  def show
    @resource = @import_source_file = Spree::ImportSourceFile.find params[:id]
    respond_with(@resource) do |format|
      format.html
      format.text { render text: @resource.data }
    end
  end

  def create
    sanitized   = params.slice :import_source_file, :import
    file        = sanitized[:import_source_file][:data]
    source_file = Spree::ImportSourceFile.new data: file.read, mime: "text/csv", file_name: file.path

    if source_file.save
      if sanitized[:import]
        source_file.import!
      end
      render json: {
        warnings: source_file.import_warnings,
        errors: source_file.import_errors,
        imported_records: source_file.imported_records
      }
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
    respond_with @collection
  end
end

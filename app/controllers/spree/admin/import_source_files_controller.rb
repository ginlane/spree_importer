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
        status = source_file.import_errors.blank?? :ok : :unprocessable_entity
      end

      render json: {
        file_id:  source_file.id,
        warnings: source_file.import_warnings,
        errors:   source_file.import_errors,
        imported_records: source_file.imported_records
      }, status:  status

    else
      render json: source_file.errors, status: :unprocessable_entity
    end

  end

  def import_from_google
    raise GoogleDrive::AuthenticationError.new if spree_current_user.google_token.nil?

    resource.import_from_google! spree_current_user.google_token
    redirect_to admin_import_source_files_path

  rescue GoogleDrive::AuthenticationError
    session[:google_oauth_return_path] = admin_import_source_files_path
    redirect_to admin_google_auth_path
  end

  def edit_in_google
    raise GoogleDrive::AuthenticationError.new if spree_current_user.google_token.nil?

    if resource.spreadsheet_url.nil?
      resource.create_in_google! spree_current_user.google_token
    end
    redirect_to resource.spreadsheet_url

  rescue GoogleDrive::AuthenticationError
    session[:google_oauth_return_path] = admin_import_source_file_show_in_google_path resource
    redirect_to admin_google_auth_path
  end

  def show_in_google
    if resource.spreadsheet_url.nil?
      flash[:error] = "No Google spreadhseet for this import file."
      redirect_to admin_import_source_files_path
    else
      redirect_to resource.spreadsheet_url
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

  protected
  def resource
    @resource ||= Spree::ImportSourceFile.find params[:import_source_file_id]
  end
end

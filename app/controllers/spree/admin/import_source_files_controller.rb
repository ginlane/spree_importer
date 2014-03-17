class Spree::Admin::ImportSourceFilesController < Spree::Admin::ResourceController

  rescue_from GoogleDrive::AuthenticationError, with: :google_authenticate

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

  def create_from_url
    ss_key = sanitized[:spreadsheet_key]

    if @source_file = Spree::ImportSourceFile.find_by(spreadsheet_key: ss_key)
      render json: { redirect:  admin_import_source_file_url(@source_file) } and return
    end

    @return_path = admin_import_source_files_url # in case google bombs out.
    @source_file = Spree::ImportSourceFile.new spreadsheet_key: ss_key
    @source_file.import_from_google! spree_current_user.google_token

    render_source_file

  rescue GoogleDrive::AuthenticationError
    render json: { error: :invalid_token }, status: :unauthorized
  end

  def create
    file         = sanitized[:data]
    @source_file = Spree::ImportSourceFile.new({
          data: file.read,
          mime: "text/csv",
          file_name: file.original_filename
      })

    @source_file.save
    @source_file.import!
    @source_file.save
    
    if @source_file.errors.blank?
      render_source_file
    else
      render json: @source_file.errors, status: :unprocessable_entity
    end
  end

  def import_from_google
    raise GoogleDrive::AuthenticationError.new if spree_current_user.google_token.nil?
    resource.import_from_google! spree_current_user.google_token, params[:worksheet]
    redirect_to admin_import_source_files_path
  end

  def edit_in_google
    raise GoogleDrive::AuthenticationError.new if spree_current_user.google_token.nil?

    if resource.spreadsheet_url.nil?
      resource.create_in_google! spree_current_user.google_token
    end
    redirect_to resource.spreadsheet_url
  end

  def show_in_google
    if resource.spreadsheet_url.nil?
      flash[:error] = "No Google spreadhseet for this import file."
      redirect_to admin_import_source_files_path
    else
      redirect_to resource.spreadsheet_url
    end
  end

  def create_google
    raise GoogleDrive::AuthenticationError.new if spree_current_user.google_token.nil?
    session   = GoogleDrive.login_with_oauth spree_current_user.google_token
    
    next_id = Spree::ImportSourceFile.last.try(:id) || 0
    next_id += 1
    ss = session.create_spreadsheet("#{Spree::Config[:site_name]} Batch Import ##{next_id}")
    ws = ss.worksheets.first
    ws.title = 'Initial'

    ws.save

    isf = Spree::ImportSourceFile.create spreadsheet_key: ss.key

    redirect_to ss.human_url
  end

  def export_to_google
    raise GoogleDrive::AuthenticationError.new if spree_current_user.google_token.nil?

    ws = resource.flat_worksheet spree_current_user.google_token
    SpreeImporter::Exporter.new(search: {batch_id_eq:resource.id}, target: :variant).each_with_index do |r,y| 
      CSV.parse(r).first.each_with_index do |c,x| 
        ws[(y+1),(x+1)] = c
      end
    end
    ws.save 
    redirect_to :back
  end

  def update
    source_file = Spree::ImportSourceFile.find params[:id]
    source_file.import!
    render json: true
  end


  def collection
    super.includes({products: [:taxons, {master: :default_price}]}, :variants)
  end

  protected

  attr_accessor :sanitized

  def google_authenticate
    session[:google_oauth_return_path] = return_path || request.referer
    redirect_to admin_google_auth_path
  end

  def resource
    @resource ||= Spree::ImportSourceFile.find params[:import_source_file_id]
  end

  def return_path
    @return_path
  end

  def sanitized
    @sanitized ||= params.require(:import_source_file).permit(:data, :spreadsheet_key)
  end

  def render_source_file
    status = @source_file.import_errors.blank?? :ok : :unprocessable_entity
    render json: {
      file_id:  @source_file.id,
      warnings: @source_file.import_warnings,
      errors:   @source_file.import_errors,
      imported_records: @source_file.imported_records
    }, status:  status
  end
end

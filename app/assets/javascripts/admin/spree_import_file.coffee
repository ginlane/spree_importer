(exports ? this).SpreeImportFile = class SpreeImportFile
  constructor: ->
    @initializeDropzone()
    @initializeWarningsTable()

  initializeDropzone: =>
    return unless !!$("#new_import_source_file").length

    @dropzone = new Dropzone "#new_import_source_file", {
      paramName: "import_source_file[data]",
      parallelUploads: 1
    }

    @dropzone.on "error", @handleError
    @dropzone.on "success", @handleSuccess
    @dropzone.on "sending", @startProgress

    @urlImport = $ "#import_from_url"
    @urlImport.on "submit", @createImportFile
    @oAuthCheck()

  initializeWarningsTable: =>
    $table = $ "#import_table table"
    return unless !!$table.length

    @info  = $("#import_table").data "import"
    @formatTable $table, @info

  formatTable: ($table, info) =>
    "option property prototype product".split(" ").forEach (k) =>
      $table.find("." + k + "-totals").html info.imported_records[k]
      @formatMessages($table, info.warnings, k)
      @formatMessages($table, info.errors, k)

    $table.parent().fadeIn()
    $table.find(".warnings").click @showMessages


  handleError: (f, err) =>
    @stopProgress()
    if err.data
      $("#error_message p:first").html "Duplicate upload"
      $("#error_message").fadeIn()
    else
      @formatErrors(err)

  handleSuccess: (file, info) =>
    @stopProgress()
    @info = info
    $table = $("#last_import table")
    @formatTable $table, info

  formatErrors: (error) =>
    html = "<tr><th>CSV Formatting Errors</th><th>#{@editButton(error.file_id)}</th></tr>"
    error.errors.forEach (e) =>
      html += "<tr class='odd'><td colspan=2>" + e.message + "</td></tr>"
    $("#last_import table").html(html)
    $("#last_import").fadeIn()


  formatMessages: ($table, info, key) =>
    return unless info[key]
    container = $table.find("." + key + "-warnings")
    string    = "<div class='number'>" + info[key].length + "</div>"
    string   += "<div class='hidden full'><ul><li>" + info[key].join("</li><li>") + "</li></ul></div>"
    container.html(string)

  showMessages: (e) =>
    $row  = $(e.currentTarget)
    label = $row.data("message-row")
    html  = ""
    "option property prototype product".split(" ").forEach (k) =>
      return unless @info[label][k]
      html += "<tr><th colspan='5'>" + k + " " + label + "</th></tr>"
      html += "<tr><td colspan='5'>"
      html += @info[label][k].join("</td></tr><tr><td colspan='5'>")
      html += "</td></tr>"

    $row.replaceWith html

  startProgress: =>
    $("#progress").stop(true, true).fadeIn()
    spinner = new Spinner(@progressOpts).spin(document.getElementById("spinner"))
  stopProgress: =>
    $("#progress").fadeOut()

  oAuthCheck: =>
    $check   = $("#oauth_check")
    ajaxOpts =
      type: "get"
      dataType: "json"
      url: $check.data("check-google")
      success: (authorized) =>
        if authorized
          $check.hide()
        else
          $("#import_from_url").hide()

    $.ajax ajaxOpts

  createImportFile: (e) =>
    e.preventDefault()
    ajaxOpts =
      type: "post"
      dataType: "json"
      data: { "import_source_file[spreadsheet_key]": $("#human_url").val() }
      url: $("#import_from_url").attr("action")
      success: (response) =>
        if response.redirect
          window.location = response.redirect
        else
          @handleSuccess response
      error: (xhr) =>
        response = JSON.parse xhr.responseText
        if response.redirect
          window.location = response.redirect
        else
          @handleError response

    $.ajax ajaxOpts


  progressOpts:
    lines: 11
    length: 2
    width: 3
    radius: 9
    corners: 1
    rotate: 0
    color: '#fff'
    speed: 0.8
    trail: 48
    shadow: false
    hwaccel: true
    className: 'spinner'
    zIndex: 2e9
    top: 'auto'
    left: 'auto'


  editButton: (fileId) =>
    """
    <form target="_blank"
          action="/admin/import_source_files/#{fileId}/edit_in_google" class="button_to" method="post">
      <div><input name="_method" type="hidden" value="put">
        <input type="submit" value="Edit">
        <input name="authenticity_token" type="hidden" value="#{AUTH_TOKEN}">
      </div>
    </form>
    """
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


  initializeWarningsTable: =>
    $table = $("#import_table table")
    return unless !!$table.length

    @info  = $("#import_table").data("import")
    @formatTable $table, @info

  formatTable: ($table, info) =>
    "option property prototype product".split(" ").forEach (k) =>
      $table.find("." + k + "-totals").html info.imported_records[k]
      @formatMessages($table, info.warnings, k)
      @formatMessages($table, info.errors, k)

    $table.parent().fadeIn()
    $table.find(".warnings,.errors").click @showMessages


  handleError: (f, err) =>
    # fnord

  handleSuccess: (file, info) =>
    @info = info
    $table = $("#last_import table")
    @formatTable $table, info

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

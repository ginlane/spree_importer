(exports ? this).SpreeImportFile = class SpreeImportFile
  constructor: ->
    @dropzone = new Dropzone "#new_import_source_file", {
      paramName: "import_source_file[data]",
      parallelUploads: 1
    }

    @dropzone.on "error", @handleError
    @dropzone.on "success", @handleSuccess

  handleError: (f, err) =>
    # fnord

  handleSuccess: (file, info) =>
    table = $("#last_import table")
    "option property prototype product".split(" ").forEach (k) =>
      console.log(k, info.imported_records[k])
      table.find("." + k + "-totals").html info.imported_records[k]
      @formatWarnings(table, info.warnings, k)

    $("#last_import").fadeIn()

  formatWarnings: (table, info, key) =>
    return unless info[key]
    container = table.find("." + key + "-warnings")
    string    = "<div class='number'>" + info[key].length + "</div>"
    string   += "<div class='hidden full'><ul><li>" + info[key].join("</li><li>") + "</li></ul></div>"

    container.html(string)
    container.click (e) =>
      $targ = e.target
      $targ.find(".full").show()
      $targ.find(".number").hide()

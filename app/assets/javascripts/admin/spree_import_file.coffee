(exports ? this).SpreeImportFile = class SpreeImportFile
  constructor: ->
    @dropzone = new Dropzone "#new_import_source_file", {
      paramName: "import_source_file[data]",
      parallelUploads: 1
    }

    @dropzone.on "error", @handleError
    @dropzone.on "success", @handleSuccess

  handleError: (f, err) =>
    # errrrr
    console.log "ERRRRRRR", f, err

  handleSuccess: (file, info) =>
    console.log info

#= require admin/dropzone
Dropzone.autoDiscover = false
$(document).ready ->
  dropzone = new Dropzone "#new_import_source_file", {
    paramName: "import_source_file[data]",
    parallelUploads: 1
  }

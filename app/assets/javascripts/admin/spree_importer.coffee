#= require admin/dropzone
#= require admin/spree_import_file
Dropzone.autoDiscover = false

$(document).ready ->
  importer = new SpreeImportFile()

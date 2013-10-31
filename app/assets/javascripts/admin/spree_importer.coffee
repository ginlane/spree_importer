#= require admin/dropzone
#= require admin/spree_import_file
#= require admin/spree_exporter
Dropzone.autoDiscover = false

$(document).ready ->
  importer = new SpreeImportFile()
  exporter = new SpreeExporter()
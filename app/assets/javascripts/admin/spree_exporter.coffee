(exports ? this).SpreeExporter = class SpreeExporter
  constructor: ->
    $("#admin_export_product,#admin_export_order").on "click", @addQueryString

  addQueryString: (e) =>

    $a  = $(e.currentTarget)
    url = $a.attr "href"
    loc = window.location.search
    if !!loc
      $a.attr "href", url + loc
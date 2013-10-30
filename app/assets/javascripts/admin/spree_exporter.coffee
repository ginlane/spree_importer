(exports ? this).SpreeExporter = class SpreeExporter
  constructor: ->
    $("#admin_export_product").on "click", @addQueryString

  addQueryString: (e) =>

    $a  = $(e.currentTarget)
    url = $a.attr "href"
    loc = window.location.search
    if !!loc
      console.log(url + loc)
      $a.attr "href", url + loc
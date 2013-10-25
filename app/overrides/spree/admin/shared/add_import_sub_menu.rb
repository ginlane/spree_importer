Deface::Override.new(virtual_path: "spree/admin/shared/_product_sub_menu",
                     name: "add_import_sub_menu",
                     insert_bottom: "[data-hook='admin_product_sub_tabs']",
                     text: "<%= tab :import_source_files, label: 'import'%>")

Deface::Override.new(virtual_path: "spree/admin/products/index",
                     name: "add_export_sub_menu",
                     insert_after: "#new_product_link",
                     text: "<li><%= button_link_to Spree.t(:export_products), admin_export_products_url(format: :csv), id: 'admin_export_product', icon: 'icon-' %></li>")

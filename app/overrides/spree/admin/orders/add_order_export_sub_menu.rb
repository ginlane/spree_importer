Deface::Override.new(virtual_path: "spree/admin/orders/index",
                     name: "add_order_export_sub_menu",
                     insert_after: "#new_order_link",
                     text: "<li><%= button_link_to Spree.t(:export_orders), admin_export_orders_url(format: :csv), id: 'admin_export_order', icon: 'icon-' %></li>")

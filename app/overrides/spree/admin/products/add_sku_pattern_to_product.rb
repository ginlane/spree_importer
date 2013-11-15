Deface::Override.new(virtual_path: "spree/admin/products/_form",
                     name: "add_sku_pattern_to_product",
                     insert_after: "erb[loud]:contains('f.field_container :available_on')",
                     text: %Q{

<%= f.field_container :sku_pattern do %>
      <%= f.label :sku_pattern, Spree.t(:sku_pattern) %>
      <%= f.error_message_on :sku_pattern %>
      <%= f.text_field :sku_pattern, size: "25" %>
<% end %>

})

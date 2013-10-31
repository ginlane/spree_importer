 module SpreeImporter
  module Exporters
    module Base
      extend ActiveSupport::Concern
      def prefix
        nil
      end
      module ClassMethods
        def target(klass)
          define_method :target do
            klass
          end
        end

        def prefix(p)
          define_method :prefix do
            p
          end
        end

        def header_attrs(*attrs)
          define_method :header_attrs do
            attrs
          end
        end

        def product_attr(attr)
          define_method :product_attribute do
            attr
          end
        end

        def has_options
          define_method :has_options? do
            true
          end
        end
      end
      def has_options?
        false
      end
      def headers(product)
        [ product.send(product_attribute) ].flatten.map do |instance|
          header_attrs.map do |attr|
            field  = ""
            option = nil
            if attr.is_a? Array
              a1, a2 = attr.map {|a| instance.send a }.compact
              if a2.nil?
                field = a1
              else
                field  = a2
                option = a1
              end
            else
              field = instance.send attr
            end
            Field.to_field_string field, option: option, kind: prefix
          end
        end.flatten
      end
    end
  end
end

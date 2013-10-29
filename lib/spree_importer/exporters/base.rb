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
      end

      def headers(product)
        [ product.send(product_attribute) ].flatten.map do |instance|
          header_attrs.map do |attr|
            if attr.is_a? Array
              a1, a2 = attr.map {|a| instance.send a }.compact
              if a2.nil? || a1 == a2
                header = a1
              else
                header = "(#{a1})#{a2}"
              end
            else
              header = instance.send attr
            end
            prefix.nil?? header : "[#{prefix}]#{header}"
          end
        end.flatten
      end
    end
  end
end

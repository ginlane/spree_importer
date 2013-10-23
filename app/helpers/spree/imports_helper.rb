module Spree::ImportsHelper
  def method_missing(method, *args)
    if method =~ /^import_(.+)$/
      call_import $1, args.shift, *args
    else
      super
    end
  end

  def call_import(target, importer, args = nil)
    target = target.singularize.to_sym
    if target == :product && args
      importer.import target # auto creates product
    else
      (args || [ ]).each do |arg|
        importer.import target, "#{target}_name".to_sym => arg, create_record: true
      end
    end
  end
end

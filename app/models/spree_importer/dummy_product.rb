class SpreeImporter::DummyProduct
  def name
    "Product Name"
  end

  def description
    "Description"
  end

  def sku_pattern
    "<master>-<size>-<color>"
  end

  def sku
    "SKU_HERE"
  end

  def price
    9.99
  end

  def available_on
    1.year.ago
  end

  def meta_description
    "Meta Description"
  end

  def meta_keywords
    "Meta Keywords"
  end

  def cost_price
    2.99
  end

  def property(name)
    "Property Value"
  end

  def master_sku
    "MASTER-#{sku}"
  end

  def stock_items
    [ ]
  end

  def variants
    @variants ||= [ SpreeImporter::DummyProduct.new ]
  end

  def taxons
    @taxons ||= [ SpreeImporter::DummyTaxon.new ]
  end

  def option_types
    @option_types ||= [ SpreeImporter::DummyOptionType.new ]
  end

  def properties
    @property    ||= SpreeImporter::DummyProperty.new
    @properties  ||= [ @property ]
  end
end

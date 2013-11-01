class SpreeImporter::DummyOptionValue
  attr_accessor :name, :presentation
  def initialize(attrs = { })
    attrs             = attrs.with_indifferent_access
    self.name         = attrs[:name]
    self.presentation = attrs[:presentation]
  end
end

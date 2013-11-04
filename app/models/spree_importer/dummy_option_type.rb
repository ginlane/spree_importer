class SpreeImporter::DummyOptionType
  def name
    "option_type"
  end
  def presentation
    "Option Type"
  end

  def option_values
    @option_values ||= [
     SpreeImporter::DummyOptionValue.new(name: "option1", presentation: "O1"),
     SpreeImporter::DummyOptionValue.new(name: "option2", presentation: "O2")
    ]
  end
end

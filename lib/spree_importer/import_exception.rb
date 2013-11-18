module SpreeImporter
  class ImportException < Exception
    attr_accessor :row, :column, :column_index
    def initialize(message, location)
      self.row          = location[:row]
      self.column       = location[:column]
      self.column_index = location[:column_index]
      super "#{message} at row: #{row}, column: #{column}"
    end

    def as_json(options = { })
      { row: row, column: column, message: message }
    end
  end
end

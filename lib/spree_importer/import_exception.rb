module SpreeImporter
  class ImportException < Exception
    attr_accessor :row, :column
    def initialize(row, column, message)
      self.row    = row
      self.column = column
      super "#{message} at row: #{row}, column: #{column}"
    end
  end
end

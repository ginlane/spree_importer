module SpreeImporter
  class Field
    attr_accessor :index, :option, :sanitized, :raw
    def initialize(field, index=nil)
      field          = field.strip
      self.raw       = field
      self.index     = index
      self.sanitized = field.gsub(/\(.+?\)/, '').parameterize "_"
      self.option    = field.scan(/\((.+?)\)/).last.try :last
    end

    def option?
      !!option
    end
    def hash
      raw.hash
    end
    def eql?(other)
      other.raw.eql? raw
    end
  end
end

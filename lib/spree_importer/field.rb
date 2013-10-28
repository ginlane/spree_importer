module SpreeImporter
  class Field
    attr_accessor :index, :kind, :option, :sanitized, :raw
    def initialize(field, header=false)
      field          = field.strip
      self.raw       = field
      self.index     = index
      self.sanitized = label.parameterize "_"
      self.option    = field.scan(/\((.+?)\)/).last.try :last
      self.kind      = field.scan(/\[(.+?)\]/).last.try :last
      @header        = header
    end
    def label
      raw.gsub(/\(.+?\)/, '').gsub /\[.+\]/, ''
    end
    def header?
      @header
    end
    def option?
      !!option
    end
    def kind?
      !!kind
    end
    def hash
      raw.hash
    end
    def eql?(other)
      other.raw.eql? raw
    end
  end
end

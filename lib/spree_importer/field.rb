module SpreeImporter
  class Field
    attr_accessor :index, :kind, :option, :sanitized, :raw
    def initialize(field, header=false)
      @header        = header
      return if field.nil?

      field          = field.strip
      self.raw       = field
      self.index     = index
      self.sanitized = label.parameterize "_"
      self.option    = field.scan(/\((.+?)\)/).last.try :last
      self.kind      = field.scan(/\[(.+?)\]/).last.try :last
    end
    def label
      return if raw.nil?
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
    def to_s
      self.class.to_field_string sanitized, option: option, kind: kind
    end
    def self.to_field_string(string, params = { })
      if params[:option] && params[:option] != string
        string = "(#{params[:option]})#{string}"
      end
      if params[:kind]
        string = "[#{params[:kind]}]#{string}"
      end
      string
    end
  end
end

module SpreeImporter
  class Field
    attr_accessor :index, :kind, :option, :sanitized, :raw
    def initialize(field, options = { header: false })
      @header        = options[:header]
      return if field.nil?

      field          = field.strip
      self.raw       = field.strip
      self.index     = options[:index]
      self.sanitized = label.parameterize SpreeImporter.config.field_space_delemiter
      self.option    = field.scan(/\((.+?)\)/).last.try :last
      self.kind      = field.scan(/\[(.+?)\]/).last.try :last
    end
    def key
      option || sanitized
    end
    def label
      return if raw.nil?
      raw.gsub(/\(.+?\)/, '').gsub(/\[.+\]/, '').strip
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
    def =~(other)
      match other
    end
    def match(regexp)
      regexp =~ to_s
    end
    def to_s
      self.class.to_field_string label, option: option, kind: kind
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

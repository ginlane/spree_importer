module SpreeImporter
  class SkuInterpolator

    # SKU segments are interpolated from option type names inside
    # angle brackets, with <master> being reserved for the master sku
    # component of a variant. a `*` wildcard will take all remaining
    # option values and append them. For example:
    #
    # master sku | color      | size      | weight | sku pattern
    # ----------------------------------------------------------------------
    # MASTER     | (bl)Blue   | (lg)Large | 50     | <master>-<size>-<color>  => MASTER-LG-BL
    # ----------------------------------------------------------------------
    # MASTER     | (bl)Blue   | (lg)Large | 50     | <master>-*               => MASTER-BL-LG-50
    # ----------------------------------------------------------------------
    # MASTER     | (bl)Blue   | (lg)Large | 50     | <master>-<size>-*        => MASTER-LG-BL-50
    #
    def initialize(pattern)
      @pattern = pattern.dup

      if @pattern =~ /\*$/
        @pattern.chop!
        @wildcard = true
        @last_sep = @pattern.last
        @pattern.chop!
      end

      @structure = @pattern.scan(/<([a-z_]+)>(.?)/).transpose.first
    end

    def to_sku(master, option_pairs)
      sku = @pattern.dup
      sku.sub! /<master>/, master

      structured_options = [ ]
      option_pairs.delete_if do|(name, option)|
        @structure.include? name and structured_options << [ name, option ]
      end

      @structure.each do |segment|
        structured_options.each do |(name, option)|
          if segment == name
            sku.sub! /<#{segment}>/, option.name.upcase
          end
        end
      end

      if @wildcard
        option_pairs.each do |(name, option)|
          sku << @last_sep
          sku << option.name.upcase
        end
      end

      sku
    end

  end
end

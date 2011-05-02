module ActiveRecord

  class Relation
    attr_accessor :ranks

    alias_method :orig_to_a, :to_a
    alias_method :orig_initialize, :initialize

    def initialize(klass, table)
      @ranks = {}
      orig_initialize(klass, table)
    end

    def to_a
      return orig_to_a if @ranks.empty?
      orig_to_a.sort do |x, y|
        @ranks[y.id] <=> @ranks[x.id]
      end
    end
  end

end
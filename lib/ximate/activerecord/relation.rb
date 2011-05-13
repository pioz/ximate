module ActiveRecord

  class Relation
    attr_accessor :ranks

    alias_method :orig_initialize, :initialize
    alias_method :orig_order, :order
    # alias_method :orig_to_a, :to_a

    def initialize(klass, table)
      @ranks = {}
      orig_initialize(klass, table)
    end

    def order(*args)
      if !@ranks.empty? && args[0] =~ /^rank/i
        tokens = args[0].split(' ')
        verse = tokens[1] if tokens[1] =~ /^(asc|desc)$/i
        verse ||= 'ASC'
        id_ordered = @ranks.keys.sort{|x,y| @ranks[x] <=> @ranks[y]}
        orig_order("FIELD(id,#{id_ordered.join(',')}) #{verse}")
      else
        orig_order(args)
      end
    end

    # def to_a
    #   return orig_to_a if @ranks.empty?
    #   orig_to_a.sort do |x, y|
    #     @ranks[y.id] <=> @ranks[x.id]
    #   end
    # end
  end

end
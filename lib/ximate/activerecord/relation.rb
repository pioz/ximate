module ActiveRecord

  class Relation
    attr_accessor :ranks

    alias_method :orig_order, :order

    def order(*args)
      @ranks ||= {}
      if args[0] =~ /^rank/i
        unless @ranks.empty?
          tokens = args[0].split(' ')
          verse = tokens[1] if tokens[1] =~ /^(asc|desc)$/i
          verse ||= 'ASC'
          id_ordered = @ranks.keys.sort{|x,y| @ranks[x] <=> @ranks[y]}
          orig_order("FIELD(id,#{id_ordered.join(',')}) #{verse}")
        else
          scoped
        end
      else
        orig_order(args)
      end
    end

  end

end

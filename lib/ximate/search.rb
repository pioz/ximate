module Ximate

  DATA = {}
  OPTIONS = {:order_by_rank => true}

  def self.included(base)
    base.extend(Search)
  end


  module Search
    def define_index(locale = I18n.default_locale, &block)
      table = self.to_s.underscore.pluralize.to_sym
      DATA[locale.to_sym] ||= {}
      DATA[locale.to_sym][table] ||= {}

      extend  ClassMethods
      include InstanceMethods

      after_save :update_index

      self.to_s.classify.constantize.all.each do |p|
        p.update_index(locale, &block)
      end

    end
  end


  module ClassMethods

    def asearch(pattern)
      table = self.to_s.underscore.pluralize.to_sym
      matches = {}
      DATA[I18n.locale] ||= {}
      DATA[I18n.locale][table] ||= {}
      DATA[I18n.locale][table].each do |word, ids|
        if Fuzzy.equal(word, pattern.downcase, 20)
          puts word
          ids.each {|id, rank| matches[id] = matches[id].to_i + rank}
        end
      end
      puts matches.inspect
      return where('1 = 0') if matches.empty?
      rel = scoped
      rel.ranks = matches if OPTIONS[:order_by_rank]
      rel.where("#{table}.id IN (#{matches.keys.join(',')})")
    end
  end


  module InstanceMethods

    def add_text(text)
      @words ||= []
      @words += text.to_s.gsub(/<[^>]*>/i, ' ').gsub(/[\.,'":;!\?\(\)]/, ' ').split(' ').map{|word| word.downcase}
    end

    def update_index(locale = I18n.default_locale, &block)
      table = self.class.to_s.underscore.pluralize.to_sym
      remove_index(locale)
      instance_eval(&block)
      @words.each do |word|
        ids = (DATA[locale.to_sym][table][word] ||= {})
        ids[self.id] ||= 0
        ids[self.id] += 1
      end
    end

    def remove_index(locale)
      table = self.class.to_s.underscore.pluralize.to_sym
      @words = []
      DATA[locale.to_sym][table].each do |word, ids|
        ids.delete(self.id)
        DATA[locale.to_sym][table].delete(word) if ids.empty?
      end
    end

  end

end
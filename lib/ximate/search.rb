module Ximate

  DATA = {}
  OPTIONS = {:match_error_percent => 20,
             :ignore_word_short_than => 2,
             #:order_by_rank => true,
             :logger => true,
             :debug => false}

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

      after_save { |proc| proc.update_index(I18n.locale, &block) }

      now = Time.now
      self.to_s.classify.constantize.all.each do |p|
        p.update_index(locale, &block)
      end
      puts "\b\b=> Build XIMATE hash data for '#{table}' in #{Time.now - now}s." if OPTIONS[:logger]
    end
  end


  module ClassMethods

    def asearch(pattern)
      table = self.to_s.underscore.pluralize.to_sym
      matches = {} # {id => rank, id => rank}
      lastsearch = {} # Save last 'e' search for every word in pattern to avoid multi-search of the same word
      pattern.split(' ').each { |w| lastsearch[w] = -1 }
      DATA[I18n.locale] ||= {}
      DATA[I18n.locale][table] ||= {}
      DATA[I18n.locale][table].each do |word, ids_ranks|
        pattern.split(' ').each do |w|
          if w.size > OPTIONS[:ignore_word_short_than]
            if e = Fuzzy.equal(word, w.downcase, OPTIONS[:match_error_percent])
              if e > lastsearch[w]
                lastsearch[w] = e
                Rails.logger.debug("XIMATE asearch: '#{word}' match with '#{w}' (e = #{e})") if OPTIONS[:debug]
                ids_ranks.each { |id, rank| matches[id] = matches[id].to_i + (e**rank) }
              end
            end
          end
        end
      end
      return where('1 = 0') if matches.empty?
      #rel = scoped
      #rel.ranks = matches if OPTIONS[:order_by_rank]
      #rel.where("#{table}.id IN (#{matches.keys.join(',')})")
      select("*, #{gen_if_select(matches)} AS RANK").where("#{table}.id IN (#{matches.keys.join(',')})")
    end

    private

    def gen_if_select(matches)
      tmp = 'IF(id=myid,myrank,if)'
      str = 'IF(id=myid,myrank,if)'
      matches.each do |id, rank|
        str.gsub!('myid', id.to_s)
        str.gsub!('myrank', rank.to_s)
        str.gsub!('if', tmp)
      end
      return str.gsub(tmp, '0')
    end

  end


  module InstanceMethods

    def add_text(text, priority = 1)
      @words ||= {}
      @words[priority] ||= []
      @words[priority] += text.to_s.gsub(/<[^>]*>/i, ' ').gsub(/[\.,'":;!\?\(\)]/, ' ').split(' ').map{|word| word.downcase}.uniq
    end

    def update_index(locale = I18n.default_locale, &block)
      table = self.class.to_s.underscore.pluralize.to_sym
      remove_index(locale)
      instance_eval(&block)
      @words.each do |priority, words|
        words.each do |word|
          ids_ranks = (DATA[locale.to_sym][table][word] ||= {})
          ids_ranks[self.id] = ids_ranks[self.id].to_i + priority
        end
      end
    end

    def remove_index(locale)
      table = self.class.to_s.underscore.pluralize.to_sym
      @words = {}
      DATA[locale.to_sym][table].each do |word, ids_ranks|
        ids_ranks.delete(self.id)
        DATA[locale.to_sym][table].delete(word) if ids_ranks.empty?
      end
    end

  end

end
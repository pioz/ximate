require 'ximate/search'
require 'ximate/activerecord/relation'
require File.join(File.dirname(__FILE__), '../ext/fuzzy_search')

ActiveRecord::Base.send(:include, Ximate)
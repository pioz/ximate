ENV['RC_ARCHS'] = '' if RUBY_PLATFORM =~ /darwin/

require 'mkmf'

LIBDIR      = Config::CONFIG['libdir']
INCLUDEDIR  = Config::CONFIG['includedir']

HEADER_DIRS = [
  # First search /opt/local for macports
  '/opt/local/include',
  # Then search /usr/local for people that installed from source
  '/usr/local/include',
  # Check the ruby install locations
  INCLUDEDIR,
  # Finally fall back to /usr
  '/usr/include',
]

LIB_DIRS = [
  # First search /opt/local for macports
  '/opt/local/lib',
  # Then search /usr/local for people that installed from source
  '/usr/local/lib',
  # Check the ruby install locations
  LIBDIR,
  # Finally fall back to /usr
  '/usr/lib',
]

dir_config('fuzzy_search', HEADER_DIRS, LIB_DIRS)

create_makefile('fuzzy_search/fuzzy_search')
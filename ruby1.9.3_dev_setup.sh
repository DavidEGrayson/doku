#!/bin/sh
# If you are trying to get the dependenceis installed for
# doing debugging in Ruby 1.9.3, try running this script.

#wget http://rubyforge.org/frs/download.php/75414/linecache19-0.5.13.gem
#gem install linecache19-0.5.13.gem
wget http://rubyforge.org/frs/download.php/75415/ruby-debug-base19-0.11.26.gem
gem install ruby-debug-base19-0.11.26.gem -- --with-ruby-include="$rvm_path/src/$(rvm tools identifier)/"
bundle

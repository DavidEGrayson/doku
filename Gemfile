source "http://rubygems.org"

# This gem uses new features of ruby:
#   require_relative
#   Enumerator
# 
# To get access to these features in older versions, we use the
# backports gem:
gem "backports", :platforms => :ruby_18

# For development gem, these gems are recommended:
group :development do
  gem "rspec"
  gem "bundler"
  gem "jeweler", "~> 1.6.2"
  gem "rcov", ">= 0", :platforms => :mri_18
  gem "yard"
  gem "watchr"
  gem "ruby-prof", :platforms => :mri

  platform :mri_19 do
    # We need the latest version of linecache19 for debugging to work.
    # http://stackoverflow.com/questions/8251349/ruby-threadptr-data-type-error
    gem 'linecache19', :git => 'git://github.com/mark-moseley/linecache'

    # ruby-debug-base19 0.11.26 is not available on ruby gems, needs to be manually
    # preinstalled.  See ruby1.9.3_dev_setup.sh
    gem 'ruby-debug-base19', '>= 0.11.26'

    gem 'ruby-debug19'
  end
end

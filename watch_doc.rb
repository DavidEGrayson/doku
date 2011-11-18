# This watchr script lets you run the specs for this gem automatically
# whenever any of the source or spec files change.
# Go to the top level directory and run:
#
#   watchr spec/watch.rb

watch('lib/doku/.*\.rb') do |md|
  system "clear && date && rake yard"
end

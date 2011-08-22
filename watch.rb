watch('.*\.rb') do |md|
  system "clear && date && rspec --color spec.rb"
end

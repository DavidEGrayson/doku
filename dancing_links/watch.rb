watch('.*\.rb') do |md|
  system "clear && date && rspec spec.rb"
end

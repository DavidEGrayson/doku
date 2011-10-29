task :default => :spec do

end

require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.rspec_opts = %w{--color}
  spec.pattern = FileList['spec/**/*_spec.rb']
end

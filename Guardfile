#guard 'yard' do
#  watch %r{lib/.+\.rb$}
#end

require 'ruby-debug'

class Object
  def self.debug
    Debugger.start unless Debugger.started?
    debugger
  end

  def debug
    Object.debug
  end
end

debugger

guard 'rspec', :version => 2 do
  watch(%r{^spec/.+_spec\.rb$}) { "rspec" }
  watch(%r{^lib/(.+)\.rb$})     { "rspec" }
  watch('spec/spec_helper.rb')  { "rspec" }
end


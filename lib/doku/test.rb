class X
  def foo
    puts "foo"
  end

  alias :boo :foo

  def foo
    puts "foo2"
  end
end

X.new.foo
X.new.boo

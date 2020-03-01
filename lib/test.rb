class Foo
  def foo
    defined?(self.bar) != nil
  end
end

class Food < Foo
  def bar
  end
end

puts Food.new.foo
class Foo
  #attr_reader :a
  #attr_writer :a
  def a
    @a + 1
  end

  def b
    @a = 1
  end
end

f = Foo.new
f.b
#f.a += 1
print f.a

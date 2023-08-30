class base1:
    def foo(self):
        print "base1"

class base2:
    def foo(self):
        print "base2"

class sub1(base1,base2):
    pass

class sub2(base2,base1):
    pass

sub1().foo()
sub2().foo()

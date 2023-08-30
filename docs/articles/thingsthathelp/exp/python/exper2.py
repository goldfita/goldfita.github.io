#You can't overload functions in python.  So, __init__ gets squashed.
#If you want to use it from both base classes, you have to call it
#directly and pass self yourself

class base1:
    def __init__(self,a):
        print a
        base2.__init__(self,a,20)
        
    def foo(self):
        print "base1"

class base2:
    def __init__(self,a,b):
        print a*b
        
    def foo(self):
        print "base2"

class sub1(base1,base2):
    pass

class sub2(base2,base1):
    pass

sub1(10).foo()
sub2(10,10).foo()

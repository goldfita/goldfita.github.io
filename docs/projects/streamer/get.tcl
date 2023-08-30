#! /usr/local/bin/wish

label .msg -font "Courier" -textvariable txt -fg red
text .b
pack .msg

proc do_stream { arg } {
	set f [open "$arg" "r"]
	destroy .b

	for {set i 0} {![eof $f]} {incr i 1} {
		set r($i) [gets $f]
	}
	set i [expr $i-4]
	set lst [expr $i+3]
	set stl [expr $i+2]
	set ttl [expr $i+1]
	
	set tmp $r($lst)
	for {set y 1} {[string first ~ $tmp] != -1} {incr y 1} {
		set tmp "[string range $tmp [expr [string first ~ $tmp]+1] [expr [string length $tmp]-1]]"
	}
	set num $y

	set m ""
	for {} {$i >= 0} {incr i -1} {
    	set m "+$r($i)$m"
	}
	set so [socket quote.yahoo.com 80];
	set q "/d/quotes.csv?s=+$m&f=s$r($ttl)"
	puts $so "GET $q \n\n";
	flush $so
	set g [read $so];
	close $so

	set g "[string range $g [string first \" $g] [string length $g]]"
	while {[string first \n $g] != [expr [string length $g]-1]} {
    		set g "[string range $g 0 [expr [string first \n $g]-1]],[string range $g [expr [string first \n $g]+1] [expr [string length $g]-1]]"
	}

	set i 0
	set g "[string range $g 0 [expr [string length $g]-2]],"
	while {[string first , $g] != -1} {
    		set p "[string range $g 0 [expr [string first , $g]-1]]"
    		set g "[string range $g [expr [string first , $g]+1] [expr [string length $g]-1]]"
    		if {[string compare [string index $p 0] "\""] == 0} {
			set p "[string range $p 1 [expr [string length $p]-1]]"
			if {[string compare [string index $p [expr [string length $p]-1]] "\""] == 0} {
	    			set p "[string range $p 0 [expr [string length $p]-2]]"
			}
    		}
    		set results($i) $p
    		set i [expr $i+1]
	}
	set results($i) [string range $g 0 [expr [string length $g]-2]]

	text .b -font "Courier" -background grey -height [expr ($i+1)/$num] -width [string length $r($stl)]
	set out2 ""
	set out "$r($stl)";
	for {set j 0} {$j < [expr ($i+1)/$num]} {incr j 1} {
    		set save_r "$r($lst)~";
		set out2 ""
		set symb($j) "$results([expr $j*$num])"
    		for {set k 0} {$k < $num} {incr k 1} {
			set tmp "[string range $save_r 0 [expr [string first ~ $save_r]-1]]"
			set save_r "[string range $save_r) [expr [string first ~ $save_r)]+1] [expr [string length $save_r]-1]]"
			set out2 "$out2[format $tmp $results([expr $j*$num+$k])]"
    		}
		.b insert end "$out2" d($j)
		.b insert end \n
		.b tag bind d($j) <1> "exec C:/Progra~1/mozilla.org/Mozilla/mozilla.exe quote.yahoo.com/q?s=$symb($j)&d=t"
		.b tag bind d($j) <Any-Enter> ".b tag configure d($j) -foreground white -background black"
		.b tag bind d($j) <Any-Leave> ".b tag configure d($j) -foreground {} -background {}"
	}
	.b configure -state disabled -wrap none
	pack .b

	upvar txt ttt
	set ttt "$out"
	wm title . "Quotes [clock format [clock seconds] -format %I:%M:%S]"
	after [expr 20 * 1000] do_stream { "$argv" }
}

do_stream "$argv" 

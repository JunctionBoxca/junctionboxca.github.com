#!/bin/ruby

`grep ^created_at *.txt`.each_line do |line|
	field = line.split(/[ :]/)
	`mv #{field[0]} #{field[3]}-#{field[0]}`
end

#!/usr/bin/ruby -w

# Usage: Make sure ruby is installed. This file is written with Ruby 2.1.5

noun_file_name = "nounsUnsorted.txt"

# Turn this into true for more verbose debugging
debug = false

noun_file = [] # array that will store the list of nouns
substances = [] # array of substances
structures = [] # array of structures
processes = [] # array of processes
a = 0 # counter for substances
b = 0 # counter for structures
c = 0 # counter for processes

# Output noun type to html files
fA = File.new("substances.txt", "wt")
fB = File.new("structures.txt", "wt")
fC = File.new("processes.txt", "wt")
fA.puts "BEGIN"
fB.puts "BEGIN"
fC.puts "BEGIN"

# Load in nouns file, stored in an array of strings => noun_file
puts "Input value for associated noun type: "
puts "1 - substance, 2 - structure, 3 - process, 0 - terminate"

counter = 0
File.open(noun_file_name) do |infile|
    while (line = infile.gets)
        noun_file[counter] = line.delete("\n")

        puts noun_file[counter]
        STDOUT.flush
        input = gets.chomp

        if (input = 1)
            substances[a] = noun_file[counter]
            fA.puts "#{a+1}. #{substances[a]}"
            a += 1

        elsif (input = 2) 
            structures[b] = noun_file[counter]
            fB.puts "#{b+1}. #{structures[b]}"
            b += 1

        elsif (input = 3)
            processes[c] = noun_file[counter]
            fC.puts "#{c+1}. #{processes[c]}"
            c += 1
        
        end
        counter += 1
    end
end

# debug
if debug
    puts "---- Nouns ----"
    noun_file.each do |noun|
        puts noun
    end
end

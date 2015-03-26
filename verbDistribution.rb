#!/usr/bin/ruby -w

# Usage: Make sure ruby is installed. This file is written with Ruby 2.1.5
#
# ruby filter.rb > output.html

# Config files. Rename as necessary. 
# Make sure that they are in the same working directory
noun_file_name = "substrates.txt"
csv_file_name  = "relations.csv"

# Turn this into true for more verbose debugging
debug = false

# Adding more nouns to file widens domain of relations
# Adding more verbs to file narrows range of relations
noun_file = [] # array that will store the list of nouns

# Catch all file IO exceptions
begin
    # Load in nouns file, stored in an array of strings => noun_file
    counter = 0
    File.open(noun_file_name) do |infile|
        while (line = infile.gets)
            noun_file[counter] = line.delete("\n")
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

    # Create a stream from the CSV file
    csv_file  = File.new(csv_file_name);

rescue => err
    puts "Exception: #{err}"
    err
end


# Store all unique verbs as keys, and number of occurrence as value
uniqueVerbs = Hash.new

f = File.new("VerbDistribution.html", "wt")
f.puts "<ol>"

# Start buffering and reading in CSV File
while (csv_line = csv_file.gets)
    # Tokenize each CSV line by commas
    tokens = csv_line.split(",")
    
    # Store separately for better readability
    article_id = tokens[0]
    predicate = tokens[1]
    object = tokens[2]
    subject = tokens[3]
    keyword = tokens[4]

    # Some (later) lines of the CSV file has 7 arguments instead of 6
    # This will handle both cases.
    if tokens.length == 6
        timestamp = tokens[5]
    elsif tokens.length == 7
        misc = tokens[5]
        timestamp = tokens[6]
    end

    # debug
    puts "FILTERING: #{object} #{predicate} #{subject}" if debug

    # reset to false
    matched_noun = false
    object_matched = false
    subject_matched = false
    noun = ""
    
    # Find matching noun
    noun_file.each do |noun|
        noun_strip = noun.delete("\n")
        # puts "matching #{noun_strip} with #{object} and #{subject}"
        object_matched = false
        subject_matched = false
        
        # object is matched (strips noun; stores in object)
        if /#{noun_strip}/i =~ object
            object_matched = true
            matched_noun = true
            noun = object
            break
            
        # subject is matched (strips noun; stores in subject)
        elsif /#{noun_strip}/i =~ subject
            subject_matched = true
            matched_noun = true
            noun = subject
            break
        end
    end
    
    next unless matched_noun 
    
    if (matched_noun)
        f.puts "<li>#{subject} <b>#{predicate}</b> #{object}</li>"
        if (uniqueVerbs.fetch(predicate, 0) == 0)
            uniqueVerbs[predicate] = 1
        else 
            uniqueVerbs[predicate] += 1
        end
    end
end

f.puts "</ol>"



f1 = File.new("SummaryStats.html", "wt")
counter = 0
f1.puts "<p>VERB: FREQUENCY</p><ol>"
uniqueVerbs.each do |key, value|
    if (value > 15)
        f1.puts "<li>#{key}: #{value}</li>"
        counter += value
    end
end

f1.puts "<ol><br>TOTAL = #{counter}"
    

# Closes CSV stream
csv_file.close
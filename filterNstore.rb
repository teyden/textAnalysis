#!/usr/bin/ruby -w

# Usage: Make sure ruby is installed. This file is written with Ruby 2.1.5
#
# ruby filter.rb > output.html

# Config files. Rename as necessary. 
# Make sure that they are in the same working directory
noun_file_name = "uniq_nouns_00.txt"
verb_file_name = "uniq_verbs_00.txt"
csv_file_name  = "relations.csv"


# Turn this into true for more verbose debugging
debug = false


# Adding more nouns to file widens dataset
# Adding more verbs to file narrows domain of relations
noun_file = [] # array that will store the list of nouns
verb_file = [] # array that will store the list of verbs


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

    # Load in verbs file, stored in an array of strings => verb_file
    counter = 0
    File.open(verb_file_name) do |infile|
        while (line = infile.gets)
            verb_file[counter] = line.delete("\n")
            counter += 1
        end
    end

    # debug
    if debug
        puts "---- Verbs ----"
        verb_file.each do |verb|
            puts verb
        end
    end

    # Create a stream from the CSV file
    csv_file  = File.new(csv_file_name);
rescue => err
    puts "Exception: #{err}"
    err
end


# Dictionaries
objectsMatched = {} # dict with key: object, val: predicate
subjectsMatched = {} # dict with key: subject, val: predicate

# Hash table for verbs from verb_file as keys
# list of nouns from noun_file that occur with verb key are values, with
# verbMatchedObjects["secrete"][0] (first element of list of nouns) is the count
verbMatchedObjects = Hash.new
verbMatchedSubjects = Hash.new

# verbNnoun = verbNobj + verbNsubj
verbNobj = 0
verbNsubj = 0
verbNnoun = 0
tracker = [verbNnoun, verbNobj, verbNsubj]

# Add each verb from verb_file to hash tables
verb_file.each do |verb|
    verb_strip = verb.delete("\n")
    verbMatchedObjects[verb_strip] = Hash.new
    verbMatchedObjects[verb_strip]["count"] = 0
    verbMatchedObjects[verb_strip]["nouns"] = []
    
    verbMatchedSubjects[verb_strip] = Hash.new
    verbMatchedSubjects[verb_strip]["count"] = 0
    verbMatchedSubjects[verb_strip]["nouns"] = []
end



verb_strip = ""
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
    matched_verb = false
    object_matched = false
    subject_matched = false
    
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
            break
            
        # subject is matched (strips noun; stores in subject)
        elsif /#{noun_strip}/i =~ subject
            subject_matched = true
            matched_noun = true
            break
        end
    end
    
    next unless matched_noun # continue while if noun is not matched

    # Find matching verb
    verb_file.each do |verb|
        verbPred = verb.delete("\n")
        verb_strip = verbPred
#        puts "matching #{verb_strip} with #{predicate}"
        if /#{verbPred}/i =~ predicate
            matched_verb = true
            verbNnoun += 1

            if subject_matched == true
                verbNsubj += 1
                break
            elsif object_matched == true
                verbNobj += 1
                break
            end
        end
    end


    if (matched_noun and matched_verb)
        
        if object_matched
            
            verbMatchedObjects[verb_strip]["count"] += 1
            if verbMatchedObjects[verb_strip]["count"] == 1
                verbMatchedObjects[verb_strip]["nouns"] = [[object, article_id.delete("\"")]]
            else
                verbMatchedObjects[verb_strip]["nouns"] += [[object, article_id.delete("\"")]]
            end

        elsif subject_matched
            verbMatchedSubjects[verb_strip]["count"] += 1
            if verbMatchedSubjects[verb_strip]["count"] == 1
                verbMatchedSubjects[verb_strip]["nouns"] = [[subject, article_id.delete("\"")]]
            else
                verbMatchedSubjects[verb_strip]["nouns"] += [[subject, article_id.delete("\"")]]
            end
        end
    else
#            puts "FAIL: #{object} #{predicate} #{subject}"
    end
end



# Write to html
verb_index = 0
f = File.new("matchedObjects.html", "wt")
f.puts "_____ ALL OBJECTS _____"
f.puts "<br>Total objects from noun_file matched with verbs from verb_file: #{verbNobj}"
verbMatchedObjects.each {|key, value|
    x = key
    verb_index += 1
    
    value.each {|k,v|
        if k == "count"
            f.puts "<p><b>##{verb_index}: </b>verb = <b>#{x.upcase}</b>"
            f.puts "<br><i>#{v} matches</i> of the form <b>[_object_] <i>#{x}</i></b> [_subject_]:"
            f.puts "<br>object = ...</p>"
        else
            i = 0
            for noun in v do
                i += 1
                f.puts "<li> [#{i}] #{noun[0]} :: <a href='http://www.ncbi.nlm.nih.gov/pubmed/#{article_id.delete("\"")}'>source</a></li>"
            end
        end
        f.puts "</p>"
    }
}

# Write to html
verb_index = 0
f = File.new("matchedSubjects.html", "wt")
f.puts "_____ ALL SUBJECTS _____"
f.puts "<br>Total subjects from noun_file matched with verbs from verb_file: #{verbNsubj}"
verbMatchedSubjects.each {|key, value|
    x = key
    verb_index += 1
    
    value.each {|k,v|
        if k == "count"
            f.puts "<p><b>##{verb_index}: </b>verb = <b>#{x.upcase}</b>"
            f.puts "<br><i>#{v} matches</i> of the form [_object_] <b><i>#{x}</i> [_subject_]</b>:"
            f.puts "<br>subject = ...</p>"
        else
            i = 0
            for noun in v do
                i += 1
                f.puts "<li> [#{i}] #{noun[0]} :: <a href='http://www.ncbi.nlm.nih.gov/pubmed/#{article_id.delete("\"")}'>source</a></li>"
            end
        end
        f.puts "</p>"
    }
}



# Closes CSV stream
csv_file.close

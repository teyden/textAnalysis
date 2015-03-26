#!/usr/bin/ruby -w

# Usage: Make sure ruby is installed. This file is written with Ruby 2.1.5
#
# ruby filter.rb > output.html

# Config files. Rename as necessary. 
# Make sure that they are in the same working directory
noun_file_name = "substrates.txt"
verb_file_name = "uniq_verbs_01.txt"
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

# Hash table for verbs from verb_file as keys
# list of nouns from noun_file that occur with verb key are values, with
# verbMatchedObjects["secrete"][0] (first element of list of nouns) is the count
verbMatched_all = Hash.new

# verbNnoun = verbNobj + verbNsubj
verb_count = 0

# Add each verb from verb_file to hash tables
verb_file.each do |verb|
    verb_strip = verb.delete("\n")
    verbMatched_all[verb_strip] = Hash.new
    verbMatched_all[verb_strip]["MATCHES_PER_VERB"] = 0
    verbMatched_all[verb_strip]["lstof_MATCHES"] = []
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
        noun = noun_strip

        # OBJECT is matched (strips noun; stores in object)
        if /#{noun_strip}/i =~ object
            object_matched = true
            matched_noun = true
            break

#         SUBJECT is matched (strips noun; stores in subject)
        elsif /#{noun_strip}/i =~ subject
            subject_matched = true
            matched_noun = true
            break
        end
    end
    
#    next unless matched_noun # continue while if noun is not matched

    # Find matching verb
    verb_file.each do |verb|
        verbPred = verb.delete("\n")
        verb_strip = verbPred
#        puts "matching #{verb_strip} with #{predicate}"
        if /#{verbPred}/i =~ predicate
            matched_verb = true
            verb_count += 1
        end
    end

    if (matched_verb)
        verbMatched_all[verb_strip]["MATCHES_PER_VERB"] += 1
        if verbMatched_all[verb_strip]["MATCHES_PER_VERB"] == 1
            verbMatched_all[verb_strip]["lstof_MATCHES"] = [[object, subject, article_id.delete("\"")]]
        else
            verbMatched_all[verb_strip]["lstof_MATCHES"] += [[object, subject, article_id.delete("\"")]]
        end
    end
end


line = 0
verb_index = 0
f = File.new("matched-verbs.html", "wt")
f.puts "Output all verb matches <b>#{verb_count}</b>"

verbMatched_all.each {|key, value|
    verb_index += 1

    f.puts "<div style=\"color:#0000FF\" ><h2><b>##{verb_index}: </b>verb = <b>#{key.upcase}</b></h2></div>"
    f.puts "<i>#{value["MATCHES_PER_VERB"]} matches</i> of the form [subject, <i>#{key}</i>, object]:"
    
    #    threshold = 1
    # value["lstof_MATCHES"] => elements of type [object, subject, article_id]
    value["lstof_MATCHES"].each_with_index do |matches, k|
        line += 1
        f.puts "<li>[#{line}.#{verb_index}.#{k+1}] relation type = [ I:<input type=\"checkbox\" name=\"trueBox\" box=\"#{line}.#{verb_index}.#{k+1}\" /> II:<input type=\"checkbox\" name=\"trueBox\" box=\"#{line}.#{verb_index}.#{k+1}\" /> III:<input type=\"checkbox\" name=\"trueBox\" box=\"#{line}.#{verb_index}.#{k+1}\" /> ]"
        f.puts "<b>#{matches[1]}</b> <i>#{key}</i> <b>#{matches[0]}</b>"
        f.puts ":: <a href='http://www.ncbi.nlm.nih.gov/pubmed/#{matches[2]}'>link</a></li>"
        #
        #        if (threshold > 200)
        #            break
        #        end
        #
        #        threshold += 1
        
    end
}



# Closes CSV stream
csv_file.close
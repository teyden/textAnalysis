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

noun_file = [] # array that will store the list of nouns
verb_file = [] # array that will store the list of verbs


# added dictionaries for future analysis and graphing of frequency
objectsMatched = {} # dict with key: object, val: predicate
subjectsMatched = {} # dict with key: subject, val: predicate
predicatesMatched = {} # dict with key: predicate, val: list of nouns

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


index = 0
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

    # FILTER MATCHING NOUNS FIRST
    # initial variables
    matched_noun = false
    object_matched = false
    subject_matched = false
    noun_file.each do |noun|
        noun_strip = noun.delete("\n")
        # puts "matching #{noun_strip} with #{object} and #{subject}"
        object_matched = false
        subject_matched = false
        
        # object is matched
        if /#{noun_strip}/i =~ object
            object_matched = true
            matched_noun = true
            break
            
        # subject is matched
        elsif /#{noun_strip}/i =~ subject
            subject_matched = true
            matched_noun = true
            break
        end
    end

    next unless matched_noun # continue while if noun is not matched
    
    
    matched_verb = false
    verb_file.each do |verb|
        verb_strip = verb.delete("\n")
        # puts "matching #{verb_strip} with #{predicate}"
        if /#{verb_strip}/i =~ predicate
            matched_verb = true
            # puts "MATCHED VERB!!! #{verb_strip} with #{predicate}"
            break
        end
    end
    
    
    # matched_noun & matched_verb -- booleans
    # object_matched is either object or subject
    if (matched_noun and matched_verb)
        index += 1
        
        # print out statement with object bolded
        if object_matched
            puts "<p>#{index}. MATCH: <b>#{object}</b> #{predicate} #{subject} <a href='http://www.ncbi.nlm.nih.gov/pubmed/#{article_id.delete("\"")}'>link</a></p>"
            objectsMatched[object] = predicate
            predicatesMatched[predicate] += [object]
            
            # puts "<p>#{index}. SUBJECT matched:  KEY = #{subject}  VAL = #{predicate} </p>"
        
        # print out statement with subject bolded
        elsif subject_matched
            puts "<p>#{index}. MATCH: #{object} #{predicate} <b>#{subject}</b> <a href='http://www.ncbi.nlm.nih.gov/pubmed/#{article_id.delete("\"")}'>link</a></p>"
            subjectsMatched[subject] = predicate
            predicatesMatched[predicate] += [subject]
            
        end
        # puts csv_line
    else
        # puts "FAIL: #{object} #{predicate} #{subject}"
    end

end


#index = 0
## loop through predicatesMatched and print each predicate, \n, \tab, then each matched noun
#for pred in predicatesMatched
#    
#    puts "<p>#{index}. <b>#{pred}</b><br>\n"
#    
#    i = 0
#    for aNoun in predicatesMatched[pred]
#        puts "#{i}. <i>#{aNoun}</i><br>\n"
#        i++
#        
#    puts "<br></p>\n"
#    index++
#        

    



# Closes CSV stream
csv_file.close
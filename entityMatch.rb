# entityMatch.rb


class entityMatch
    verbs = {}
    subjects = {}
    objects = {}
    total_verbs = 0 

    debug = false
    total_matches = "MATCHES_PER_VERB"
    allMatches = "lstof_MATCHES"

    def stripNouns(nounFile_in) 

        nounList_out = []
        counter = 0

        File.open(nounFile_in) do |infile|
            while (line = infile.gets)
                nounList_out[counter] = line.delete("\n")
                counter += 1
            end
        end

        # debug
        if debug
            puts "---- Nouns ----"
            nounList_out.each do |noun|
                puts noun
            end
        end

        return nounList_out 
    end


    def stripVerbs(verbFile_in)

        verbFile_out = []
        counter = 0

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

        return verbList_out
    end


    def addTargetVerbs(verbList_in)
        # Add each verb from verb_file to objects and subjects
        # matchedVerbs.objects will contain all objects that match with the verb
        verbList_in.each do |verb|
            verb_strip = verb.delete("\n")
            objects[verb_strip] = Hash.new
            objects[verb_strip][total] = 0
            objects[verb_strip][allMatches] = []
            
            subjects[verb_strip] = Hash.new
            subjects[verb_strip][total] = 0
            subjects[verb_strip][allMatches] = []
        end
    end


    def addObject(key, value1, value2, info)
        # key = verb
        # value1 = "MATCHES_PER_VERB"
        # value2 = "lstof_MATCHES" 
        objects[key][count] += 1

        if objects[key][count] == 1
            objects[key][value] = [info]
        else 
            objects[key][value] += [info]
        end
    end



    def addSubject(key, value1, value2, info)
        # key = verb
        # value1 = "MATCHES_PER_VERB"
        # value2 = "lstof_MATCHES" 
        subjects[key][value1] += 1

        if subjects[key][value1] == 1
            subjects[key][value2] = [info]
        else 
            subjects[key][value2] += [info]
        end
    end



    def Stream_tofindMatches(csvFile_in, nounList_in, verbList_in)
        # input:
        # output: prints success or fail statement
        # ==> if success then noun matches get added to appropriate hash table
        # ==> objects or subjects

        # Create a stream from the CSV file
        csv_file  = File.new(csvFile_in);
        rescue => err
            puts "Exception: #{err}"
            err
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
            info = [article_id, predicate, object, subject, keyword]

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
            is_matched_noun = false
            is_matched_verb = false
            is_equiv_Object? = false
            is_equiv_Subject? = false
            

            # Make call to 
            # Find matching noun
            nounList_in.each do |noun|
                noun_strip = noun.delete("\n")
                # puts "matching #{noun_strip} with #{object} and #{subject}"
                is_equiv_Object = false
                is_equiv_Subject = false
                
                # object is matched (strips noun; stores in object)
                if /#{noun_strip}/i =~ object
                    is_equiv_Object? = true
                    is_matched_noun = true
                    break
                    
                # subject is matched (strips noun; stores in subject)
                elsif /#{noun_strip}/i =~ subject
                    is_equiv_Subject? = true
                    is_matched_noun = true
                    break
                end
            end
            
            next unless is_matched_noun # continue while if noun is not matched

            # Find matching verb
            verbList_in.each do |verb|
                predicate = verb.delete("\n")
        #        puts "matching #{verb_strip} with #{predicate}"
                if /#{verbPred}/i =~ predicate
                    is_matched_verb = true

                end
            end


            # turn this into its own method
            if (is_matched_noun and is_matched_verb)
                if is_equiv_Object?
                    addObject(predicate, "MATCHES_PER_VERB", "lstof_MATCHES", info)
                elsif is_equiv_Subject?
                    addSubject(predicate, "MATCHES_PER_VERB", "lstof_MATCHES", info)
                end
            else
        #            puts "FAIL: #{object} #{predicate} #{subject}"
            end
        end





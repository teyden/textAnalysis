# entityMatch.rb
entityMatch = Class.new do
    attr_accessor :verbs, :nouns, :subjects, :objects, :csv, :total_verbs, :nouns_in, :verbs_in, :debug

    def initialize(total_verbs = 0)
        @verbs = []
        @nouns = []
        @objects = {}
        @subjects = {}
        @total_verbs = total_verbs
        @debug = false
        total_matches = "MATCHES_PER_VERB"
        allMatches = "lstof_MATCHES"
    end


    def display(port=$>)
        port.write self 
    end


    def stripNouns
        nounFile_in = @nouns_in
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


    def stripVerbs
        verbFile_in = @verbs_in
        verbList_out = []
        counter = 0

            # Load in verbs file, stored in an array of strings => verb_file
        counter = 0
        File.open(verbFile_in) do |infile|
            while (line = infile.gets)
                verbList_out[counter] = line.delete("\n")
                counter += 1
            end
        end

        # debug
        if debug
            puts "---- Verbs ----"
            verbList_out.each do |verb|
                puts verb
            end
        end
        return verbList_out
    end



    def _addObject(key, value1, value2, info)
        # key = verb
        # value1 = "MATCHES_PER_VERB"
        # value2 = "lstof_MATCHES" 
        self.objects[key][value1] += 1

        if self.objects[key][value1] == 1
            self.objects[key][value2] = [info]
        else 
            self.objects[key][value2] += [info]
        end
    end



    def _addSubject(key, value1, value2, info)
        # key = verb
        # value1 = "MATCHES_PER_VERB"
        # value2 = "lstof_MATCHES" 
        self.subjects[key][value1] += 1

        if self.subjects[key][value1] == 1
            self.subjects[key][value2] = [info]
        else 
            self.subjects[key][value2] += [info]
        end
    end


    # addTargetVerbs() will add each verb in verbList_in as keys
    # with value: hash table with two elements, count=0 and an empty list
    # aVerb=>{numMatches=>lstof_MATCHES}
    # INPUT: list of verbs 
    # OUTPUT: none
    def addTargetVerbs
        verbList_in = @verbs
        verbList_in.each do |verb|
            verb_strip = verb.delete("\n")
            objects[verb_strip] = Hash.new
            objects[verb_strip]["MATCHES_PER_VERB"] = 0
            objects[verb_strip]["lstof_MATCHES"] = []
            
            subjects[verb_strip] = Hash.new
            subjects[verb_strip]["MATCHES_PER_VERB"] = 0
            subjects[verb_strip]["lstof_MATCHES"] = []
        end
    end

    # streamCSVforMatches() searches for matching instances of noun + verb
    # and adds noun to appropriate hash table 
    def streamCSVforMatches(csvFile_in, nounList_in, verbList_in)
        # input:
        # output: prints success or fail statement
        # ==> if success then noun matches get added to appropriate hash table
        # ==> objects or subjects


        verb_strip = ""
        # Start buffering and reading in CSV File
        while (csv_line = csvFile_in.gets)
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
            is_equiv_Object = false
            is_equiv_Subject = false
            

            # Find matching noun
            nounList_in.each do |noun|
                noun_strip = noun.delete("\n")
                # puts "matching #{noun_strip} with #{object} and #{subject}"
                is_equiv_Object = false
                is_equiv_Subject = false
                
                # object is matched (strips noun; stores in object)
                if /#{noun_strip}/i =~ object
                    is_equiv_Object = true
                    is_matched_noun = true
                    break
                    
                # subject is matched (strips noun; stores in subject)
                elsif /#{noun_strip}/i =~ subject
                    is_equiv_Subject = true
                    is_matched_noun = true
                    break
                end
            end
            
            next unless is_matched_noun # continue while if noun is not matched

            # Find matching verb
            verbList_in.each do |verb|
                verb_strip = verb.delete("\n")
        #        puts "matching #{verb_strip} with #{predicate}"
                if /#{verb_strip}/i =~ predicate
                    is_matched_verb = true
                    predicate = verb_strip
                end
            end


            if (is_matched_noun and is_matched_verb)
                if is_equiv_Object
                    self._addObject("#{verb_strip}", "MATCHES_PER_VERB", "lstof_MATCHES", info)
                elsif is_equiv_Subject
                    self._addSubject("#{verb_strip}", "MATCHES_PER_VERB", "lstof_MATCHES", info)
                end
            else
        #            puts "FAIL: #{object} #{predicate} #{subject}"
            end
        end 
        # end of while loop
    end
end


if __FILE__ == $0
    # Create a stream from the CSV file
    csv_file = File.new("relations.csv");
    T = entityMatch.new

    T.nouns_in = "uniq_nouns_00.txt"
    T.verbs_in = "uniq_verbs_00.txt"
    nounList = T.stripNouns
    verbList = T.stripVerbs
    puts verbList
    T.addTargetVerbs
    T.streamCSVforMatches(csv_file, nounList, verbList)
    # puts T.objects
end
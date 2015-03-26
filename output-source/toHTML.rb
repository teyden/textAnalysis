# toHTML.rb module


def sectionHeader(file, index, verbName, info)
    # Title
    file.puts "<div style=\"color:#0000FF\" ><h2><b>##{index}: </b>verb = <b>#{verbName.upcase}</b></h2></div>"

    # Short description 
    file.puts "<i>#{info["MATCHES_PER_VERB"]} matches</i> of the form [_object_] <b><i>verbName</i> [_subject_]</b>:"
    f.puts "<br>subject = ..."
    
    # Response? Change this
    f.puts "<form method='post' action='mailto:teydenn@gmail.com' >"
end


# verbName is a str, info is a dict 
# index is an int
# info is a hash table with two keys => {"MATCHES_PER_VERB"=>k, "lstof_MATCHES"=>[[numNouns, ["dopamine", "serotonin", 1239028]]}
# file is an HTML file
def pageHeader(fileName, data_lines)
    puts "_____ #{fileName} _____"
    puts "<br>Total subjects from noun_file matched with verbs from verb_file: #{data_lines}"
end



def addBox(HTML_LINE, VERB_INDEX, SUBJECT_LINE)
    # n = HTML_LINE
    # i = VERB_INDEX
    # m = SUBJECT_LINE
    # boxID = n.i.m  i.e. 98.3.78 
    return "<li>[#{m+1}] <input type=\"checkbox\" name=\"trueBox\" box=\"#{n}.#{i}.#{m+1}\" /> "



def addMatch(OBJ, VERB, SUBJ, ID)
    return "#{OBJ} <i><b>" + VERB + "</i> #{SUBJ}</b> :: <a href='http://www.ncbi.nlm.nih.gov/pubmed/#{ID}'>link</a></li>"



def write2HTML(hashT, N)
    # k ... N
    HTML_LINE = 0  # 
    VERB_INDEX = 0  # verb index
    # SUBJECT_LINE = 0

    f = File.new("#{hashT}", "wt")
    f.puts pageHeader("#{hashT}", N)

    hashT.each {|verb, matches|
        VERB_INDEX += 1

        # jquery script goes here
        # if this doesn't work then remove file from parameter
        sectionHeader(f, VERB_INDEX, key, value)

        matches["lstof_MATCHES"].each_with_index do |match_info, SUBJECT_LINE|
            SUBJECT_LINE += 1
            s1 = addBox(HTML_LINE, VERB_INDEX, SUBJECT_LINE)
            s2 = addMatch(match_info[0], verb, match_info[1], match_info[2])
            f.puts s1 + s2
        end
        f.puts "<br><br><input type='submit' value='Send Email'>SUBMIT</button></form>"
        #REDIRECT BUTTON TO .HTML FILE; also embed myFunction to keep track of stuff in FORM
}
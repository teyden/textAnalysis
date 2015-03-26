# Usage for module

require 'toHTML'
require 'entityMatch'

# def sectionHeader(file, index, verbName, info)
# def pageHeader(fileName, data_lines)
# def addBox(n, i, m)
    # n = HTML_LINE
    # i = VERB_INDEX
    # m = SUBJECT_LINE
    # boxID = n.i.m  i.e. 98.3.78 
# def addMatch(OBJ, VERB, SUBJ, ID)
# def write2HTML(hashT, N)


_csv = "relations.csv"
T = entityMatch.new

nounsList = T.stripNouns("noun_file_00.txt")
verbList = T.stripVerbs("verb_file_00.txt")
T.addTargetVerbs(verbList)
streamCSVforMatches(_csv, nounsList, verbsList)

puts T.objects




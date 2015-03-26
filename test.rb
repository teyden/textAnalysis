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

T = entityMatch.new
T.verbs = {}
T.objects = {}
T.subjects = {}
T.total_verbs = 0

T.stripNouns("noun_file.txt")
targets = T.stripVerbs("verb_file.txt")
T.addTargetVerbs(targets)


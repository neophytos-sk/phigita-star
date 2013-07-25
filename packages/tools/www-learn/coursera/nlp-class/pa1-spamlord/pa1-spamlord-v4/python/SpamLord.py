import sys
import os
import re
import pprint
import urllib


comment_pat = '<!-- [^>]{,10} -->'
space_pat = '(' + comment_pat + '|\s)*'
space_before_at_pat = '(' + comment_pat + '|\s|\s+[\(\[\{]\s*[a-zA-Z]{,20}\s+by[\s&a-zA-Z0-9;]{,10}[\"\']?)*'

dot_pat =  '(' + comment_pat + '|\.|\s+do?t\s+|\s*DO?T\s*|\s*DO[A-Z]\s*)'
delim_pat = '[\s\"\'><:,;\(\)\[\]\{\}&]'
delim_pat2 = '[\s\"\'><:,;\(\)\[\]\{\}&\.]'
tld_pat = '(edu|com|org|net|EDU|COM|ORG|NET)'
at_pat = '(@|\sat\s|[\(\)\[\]\-\+_]\s*at\s*[\(\)\[\]\-\+_]|&#x40;|WHERE)'

host_pat = '(\w+|\w+\.\w+|\w+\.\w+\.\w+|\w+\s+dot\s+\w+|\w+\s*' + comment_pat + '\s*\w+|\w+\s+DO?T\s+\w+|\w+\s+do?t\s+\w+|\w+\s+do?t\s+\w+\s+do?t\s+\w+|\w+\s+DO?T\s+\w+\s+DO?T\s+\w+)'

dot_pat2 = '\s+dot\s+|\s*' + comment_pat + '\s*|\s+DO?T\s+|\s+DO[A-Z]\s+|\s+do?t\s+'

user_pat = '(\w+|\w+[\._\-]\w+|\w+[\._\-]\w+[\._\-]\w+|\w+\s+do?t\s+\w+|\w+\s+DO?T\s+\w+)'
user_dot_pat = '\s+dot\s+|\s+DO?T\s+|\s+do?t\s+'

my_first_pat = '([^\s]*)' + delim_pat + user_pat + space_before_at_pat + at_pat + space_pat + host_pat + dot_pat + tld_pat + delim_pat2 + '([^\s]*)'

# only check within the context of a qualifier, such as "email:"
dot_special_pat =  '(' + comment_pat + '|\.|\s+do?t\s+|\s*DO?T\s*|\s*DO[A-Z]\s*|[;\|]|\s+)'
dot_special_pat2 = '\s+dot\s+|\s*' + comment_pat + '\s*|\s+DO?T\s+|\s+DO[A-Z]\s+|\s+do?t\s+|[;\|]|\s+'
host_pat2 = '(\w+|\w+[\s;\.]\w+|\w+[\s;\.]\w+[\s;\.]\w+)'
my_second_pat = '([^\s]*)' + delim_pat + user_pat + space_before_at_pat + at_pat + space_pat + host_pat2 + dot_special_pat + tld_pat + delim_pat2 + '([^\s]*)'


# phones
my_phones_pat = '(^|' + delim_pat2 + ')\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})(' + delim_pat2 + '|$)'

""" 
TODO
This function takes in a filename along with the file object (actually
a StringIO object at submission time) and
scans its contents against regex patterns. It returns a list of
(filename, type, value) tuples where type is either an 'e' or a 'p'
for e-mail or phone, and value is the formatted phone number or e-mail.
The canonical formats are:
     (name, 'p', '###-###-#####')
     (name, 'e', 'someone@something')
If the numbers you submit are formatted differently they will not
match the gold answers

NOTE: ***don't change this interface***, as it will be called directly by
the submit script

NOTE: You shouldn't need to worry about this, but just so you know, the
'f' parameter below will be of type StringIO at submission time. So, make
sure you check the StringIO interface if you do anything really tricky,
though StringIO should support most everything.
"""
def process_file(name, f):
    # note that debug info should be printed to stderr
    # sys.stderr.write('[process_file]\tprocessing file: %s\n' % (path))

    inside_style_tag = False
    res = []
    for line in f:

        if re.search("<style",line):
            inside_style_tag = True

        if inside_style_tag and re.search("</style>",line):
            inside_style_tag = False

        if inside_style_tag:
            continue

        unquoted_line = urllib.unquote(line)


        matches = re.findall(my_first_pat,unquoted_line)
        for m in matches:
            (prev_word,user,_SP1_,_AT_,_SP2_,host,_DOT_,tld,next_word) = m

            if next_word.lower() == "port":
                continue

            host = re.sub(dot_pat2,'.',host)
            user = re.sub(user_dot_pat,'.',user)

            email = user + '@' + host + '.' + tld
            res.append((name,'e',email))

        if len(matches)==0 and re.search("email|address|contact|at",unquoted_line,flags=re.IGNORECASE|re.M):
            special_matches = re.findall(my_second_pat,unquoted_line)

            for m in special_matches:
                (prev_word,user,_SP1_,_AT_,_SP2_,host,_DOT_,tld,next_word) = m

                if next_word.lower() == "port":
                    continue

                host = re.sub(dot_special_pat2,'.',host)
                user = re.sub(user_dot_pat,'.',user)

                email = user + '@' + host + '.' + tld
                res.append((name,'e',email))

        unquoted_line2 = re.sub('[\"\']https?://[^\"]+[\'\"]','',unquoted_line)
        phone_matches = re.findall(my_phones_pat,unquoted_line2)
        for m in phone_matches:
            (before_text,p1,p2,p3,after_text) = m

            phone = p1 + '-' + p2 + '-' + p3
            res.append((name,'p', phone))



    return res

"""
You should not need to edit this function, nor should you alter
its interface as it will be called directly by the submit script
"""
def process_dir(data_path):
    # get candidates
    guess_list = []
    for fname in os.listdir(data_path):
        if fname[0] == '.':
            continue
        path = os.path.join(data_path,fname)
        f = open(path,'r')
        f_guesses = process_file(fname, f)
        guess_list.extend(f_guesses)
    return guess_list

"""
You should not need to edit this function.
Given a path to a tsv file of gold e-mails and phone numbers
this function returns a list of tuples of the canonical form:
(filename, type, value)
"""
def get_gold(gold_path):
    # get gold answers
    gold_list = []
    f_gold = open(gold_path,'r')
    for line in f_gold:
        gold_list.append(tuple(line.strip().split('\t')))
    return gold_list

"""
You should not need to edit this function.
Given a list of guessed contacts and gold contacts, this function
computes the intersection and set differences, to compute the true
positives, false positives and false negatives.  Importantly, it
converts all of the values to lower case before comparing
"""
def score(guess_list, gold_list):
    guess_list = [(fname, _type, value.lower()) for (fname, _type, value) in guess_list]
    gold_list = [(fname, _type, value.lower()) for (fname, _type, value) in gold_list]
    guess_set = set(guess_list)
    gold_set = set(gold_list)

    tp = guess_set.intersection(gold_set)
    fp = guess_set - gold_set
    fn = gold_set - guess_set

    pp = pprint.PrettyPrinter()
    #print 'Guesses (%d): ' % len(guess_set)
    #pp.pprint(guess_set)
    #print 'Gold (%d): ' % len(gold_set)
    #pp.pprint(gold_set)
    print 'True Positives (%d): ' % len(tp)
    pp.pprint(tp)
    print 'False Positives (%d): ' % len(fp)
    pp.pprint(fp)
    print 'False Negatives (%d): ' % len(fn)
    pp.pprint(fn)
    print 'Summary: tp=%d, fp=%d, fn=%d' % (len(tp),len(fp),len(fn))

"""
You should not need to edit this function.
It takes in the string path to the data directory and the
gold file
"""
def main(data_path, gold_path):
    guess_list = process_dir(data_path)
    gold_list =  get_gold(gold_path)
    score(guess_list, gold_list)

"""
commandline interface takes a directory name and gold file.
It then processes each file within that directory and extracts any
matching e-mails or phone numbers and compares them to the gold file
"""
if __name__ == '__main__':
    if (len(sys.argv) != 3):
        print 'usage:\tSpamLord.py <data_dir> <gold_file>'
        sys.exit(0)
    main(sys.argv[1],sys.argv[2])

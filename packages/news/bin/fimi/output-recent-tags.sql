
    drop table xo.xo__buzz_recent_tags;
    create table xo.xo__buzz_recent_tags (
      occurrence integer not null
     ,itemset_size integer not null
     ,itemset_tags text not null
     ,itemset_ts_vector tsvector not null
    );
begin;
delete from xo.xo__buzz_recent_tags;

copy xo.xo__buzz_recent_tags from stdin with delimiter E'\t';
3297	0		xxx
188	1	πολιτικη 	xxx
104	1	νεα 	xxx
93	1	ελλαδα 	xxx
19	2	ελλαδα πολιτικη 	xxx
92	1	κοινωνια 	xxx
24	2	κοινωνια πολιτικη 	xxx
8	2	κοινωνια ελλαδα 	xxx
53	1	σελιδα 	xxx
79	1	internet 	xxx
3	2	internet πολιτικη 	xxx
75	1	επικαιροτητα 	xxx
49	2	επικαιροτητα πολιτικη 	xxx
3	2	επικαιροτητα κοινωνια 	xxx
37	2	αρχικη σελιδα 	xxx
64	1	πασοκ 	xxx
17	2	πασοκ πολιτικη 	xxx
5	2	πασοκ νεα 	xxx
5	2	πασοκ κοινωνια 	xxx
4	3	πασοκ κοινωνια πολιτικη 	xxx
70	1	γενικα 	xxx
66	1	ποιηση 	xxx
55	1	2008 	xxx
53	1	music 	xxx
53	1	μουσικη 	xxx
11	2	μουσικη ελλαδα 	xxx
3	2	μουσικη γενικα 	xxx
49	1	διαφορα 	xxx
46	1	blogs 	xxx
4	2	blogs πολιτικη 	xxx
3	2	blogs ελλαδα 	xxx
8	2	blogs internet 	xxx
45	1	τελευταια 	xxx
44	2	τελευταια νεα 	xxx
41	1	ασφαλιστικο 	xxx
7	2	ασφαλιστικο πολιτικη 	xxx
8	2	ασφαλιστικο νεα 	xxx
5	2	ασφαλιστικο κοινωνια 	xxx
3	2	ασφαλιστικο πασοκ 	xxx
38	1	περιβαλλον 	xxx
35	1	αθηνα 	xxx
25	2	αθηνα ελλαδα 	xxx
6	3	αθηνα μουσικη ελλαδα 	xxx
32	1	news 	xxx
12	2	news πολιτικη 	xxx
9	2	news κοινωνια 	xxx
8	3	news κοινωνια πολιτικη 	xxx
3	3	news κοινωνια ελλαδα 	xxx
4	2	news internet 	xxx
4	2	news blogs 	xxx
36	1	σκεψεις 	xxx
3	2	σκεψεις πολιτικη 	xxx
3	2	σκεψεις κοινωνια 	xxx
35	1	εργατικα 	xxx
3	2	εργατικα πολιτικη 	xxx
5	2	εργατικα ασφαλιστικο 	xxx
34	1	art 	xxx
32	1	καθε 	xxx
31	1	software 	xxx
8	2	software internet 	xxx
31	1	συνεδριο 	xxx
6	2	συνεδριο πολιτικη 	xxx
27	2	συνεδριο πασοκ 	xxx
3	3	συνεδριο πασοκ νεα 	xxx
5	2	συνεδριο 2008 	xxx
30	1	ποδοσφαιρο 	xxx
30	1	social 	xxx
15	2	social internet 	xxx
3	2	social news 	xxx
30	1	ανακοινωσεισ 	xxx
4	2	ανακοινωσεισ γενικα 	xxx
30	2	μερας καθε 	xxx
29	1	διαδικτυο 	xxx
5	2	διαδικτυο πολιτικη 	xxx
4	2	διαδικτυο νεα 	xxx
3	2	διαδικτυο ελλαδα 	xxx
5	2	διαδικτυο κοινωνια 	xxx
4	2	διαδικτυο blogs 	xxx
29	1	δικαιωματα 	xxx
6	2	δικαιωματα πολιτικη 	xxx
5	2	δικαιωματα κοινωνια 	xxx
4	3	δικαιωματα κοινωνια πολιτικη 	xxx
29	1	παιζει 	xxx
29	1	ηχου 	xxx
6	3	ηχου μερας καθε 	xxx
26	1	media 	xxx
4	2	media social 	xxx
28	1	εκδηλωσεις 	xxx
7	2	εκδηλωσεις ελλαδα 	xxx
6	3	εκδηλωσεις αθηνα ελλαδα 	xxx
28	1	τεχνολογια 	xxx
5	2	τεχνολογια internet 	xxx
27	1	οικονομια 	xxx
13	2	οικονομια πολιτικη 	xxx
8	2	οικονομια ασφαλιστικο 	xxx
10	3	οικονομια news πολιτικη 	xxx
7	4	οικονομια news κοινωνια πολιτικη 	xxx
5	4	οικονομια news ασφαλιστικο πολιτικη 	xxx
27	1	μμε 	xxx
4	2	μμε πολιτικη 	xxx
4	2	μμε πασοκ 	xxx
26	1	θεμα 	xxx
5	2	θεμα blogs 	xxx
4	2	θεμα μμε 	xxx
26	1	design 	xxx
3	2	design art 	xxx
26	1	κοσμος 	xxx
3	2	κοσμος πολιτικη 	xxx
5	2	κοσμος ελλαδα 	xxx
3	2	κοσμος θεμα 	xxx
26	1	blogging 	xxx
9	2	blogging internet 	xxx
4	2	blogging news 	xxx
6	2	blogging social 	xxx
25	1	tv 	xxx
26	1	αρης 	xxx
21	1	παπανδρεου 	xxx
7	2	παπανδρεου πολιτικη 	xxx
18	2	παπανδρεου πασοκ 	xxx
6	3	παπανδρεου πασοκ πολιτικη 	xxx
11	2	παπανδρεου συνεδριο 	xxx
4	3	παπανδρεου συνεδριο πολιτικη 	xxx
10	3	παπανδρεου συνεδριο πασοκ 	xxx
25	1	ειδησεις 	xxx
5	2	ειδησεις νεα 	xxx
25	1	by 	xxx
24	1	καθημερινα 	xxx
23	1	κινηματογραφος 	xxx
23	1	video 	xxx
4	2	video music 	xxx
24	1	παιδια 	xxx
16	2	παιδια παιζει 	xxx
3	3	παιδια ηχου παιζει 	xxx
24	1	εικονες 	xxx
7	2	εικονες ποιηση 	xxx
23	1	ιστορια 	xxx
3	2	ιστορια ελλαδα 	xxx
23	1	απεργιες 	xxx
12	2	απεργιες ασφαλιστικο 	xxx
3	3	απεργιες μμε ασφαλιστικο 	xxx
22	1	apple 	xxx
6	2	apple διαφορα 	xxx
3	2	apple software 	xxx
22	1	life 	xxx
21	1	απεργια 	xxx
5	2	απεργια ασφαλιστικο 	xxx
20	1	web 	xxx
6	2	web internet 	xxx
4	2	web blogging 	xxx
22	1	αστεια 	xxx
22	1	αφιερωμενο 	xxx
7	2	αφιερωμενο ηχου 	xxx
22	1	καρδιας 	xxx
11	2	καρδιας ηχου 	xxx
9	2	καρδιας αφιερωμενο 	xxx
4	3	καρδιας αφιερωμενο ηχου 	xxx
21	1	funny 	xxx
21	1	εγραψαν 	xxx
9	2	εγραψαν blogs 	xxx
10	2	εγραψαν θεμα 	xxx
4	3	εγραψαν θεμα blogs 	xxx
4	2	εγραψαν απεργιες 	xxx
3	3	εγραψαν απεργιες ασφαλιστικο 	xxx
21	1	γιωργος 	xxx
10	2	γιωργος παπανδρεου 	xxx
8	3	γιωργος παπανδρεου πασοκ 	xxx
4	4	γιωργος παπανδρεου πασοκ πολιτικη 	xxx
6	4	γιωργος παπανδρεου συνεδριο πασοκ 	xxx
5	2	γιωργος by 	xxx
21	1	ξαβιεροκουβεντες... 	xxx
20	1	videos 	xxx
4	2	videos internet 	xxx
3	3	videos software internet 	xxx
6	2	videos funny 	xxx
20	1	μακεδονια 	xxx
6	2	μακεδονια ελλαδα 	xxx
19	1	αποψεις 	xxx
3	2	αποψεις διαδικτυο 	xxx
12	1	iphone 	xxx
3	2	iphone software 	xxx
18	1	politics 	xxx
19	1	κοινωνικα 	xxx
16	1	τραγουδι 	xxx
11	2	τραγουδι ποιηση 	xxx
19	1	λογου 	xxx
3	3	λογου μερας καθε 	xxx
10	2	λογου ηχου 	xxx
5	2	λογου αφιερωμενο 	xxx
3	3	λογου αφιερωμενο ηχου 	xxx
7	2	λογου καρδιας 	xxx
5	3	λογου καρδιας ηχου 	xxx
3	3	λογου καρδιας αφιερωμενο 	xxx
19	1	θεσσαλονικη 	xxx
5	2	θεσσαλονικη ελλαδα 	xxx
3	2	θεσσαλονικη μουσικη 	xxx
19	1	σημερα 	xxx
12	2	σημερα παιζει 	xxx
13	1	greek 	xxx
18	1	αρθρα 	xxx
4	2	αρθρα πολιτικη 	xxx
6	3	αρθρα τελευταια νεα 	xxx
18	1	καθημερινοτητα 	xxx
5	2	καθημερινοτητα music 	xxx
18	1	blog 	xxx
3	2	blog πολιτικη 	xxx
18	3	ετουσ ανακοινωσεισ μαθηματων 	xxx
17	1	πολιτικα 	xxx
17	1	ελληνικη 	xxx
11	2	ελληνικη ποιηση 	xxx
4	3	ελληνικη τραγουδι ποιηση 	xxx
17	1	αυτισμος 	xxx
11	2	αυτισμος καθημερινα 	xxx
17	1	διεθνη 	xxx
17	1	world 	xxx
17	1	αθλητικα 	xxx
17	1	πρωτη 	xxx
16	2	πρωτη σελιδα 	xxx
17	1	προσωπικα 	xxx
17	1	βιβλια 	xxx
4	2	βιβλια καθημερινα 	xxx
3	2	βιβλια αυτισμος 	xxx
16	1	ημερολογιο 	xxx
16	1	κκε 	xxx
4	2	κκε πολιτικη 	xxx
3	2	κκε πολιτικα 	xxx
3	2	κκε διεθνη 	xxx
16	1	freeware 	xxx
7	2	freeware software 	xxx
6	2	freeware apple 	xxx
16	1	βοιωτια 	xxx
3	2	βοιωτια πασοκ 	xxx
15	1	people 	xxx
6	2	people internet 	xxx
3	2	people art 	xxx
3	2	people social 	xxx
5	2	people blogging 	xxx
4	3	people blogging internet 	xxx
5	2	people web 	xxx
4	3	people web internet 	xxx
3	4	people web blogging internet 	xxx
13	1	mac 	xxx
3	2	mac διαφορα 	xxx
3	2	mac software 	xxx
6	2	mac apple 	xxx
15	1	προτασεις 	xxx
3	2	προτασεις blogs 	xxx
3	2	προτασεις θεμα 	xxx
4	2	προτασεις θεσσαλονικη 	xxx
15	1	δημοκρατια 	xxx
10	2	δημοκρατια νεα 	xxx
5	3	δημοκρατια ασφαλιστικο νεα 	xxx
3	5	δημοκρατια γιωργος νεα πασοκ παπανδρεου 	xxx
15	1	φωτογραφια 	xxx
15	1	τυπου 	xxx
4	3	τυπου τελευταια νεα 	xxx
14	1	thessaloniki 	xxx
15	1	movies 	xxx
13	1	αλβανια 	xxx
9	2	αλβανια πολιτικη 	xxx
5	2	αλβανια μακεδονια 	xxx
15	1	εκθεσεις 	xxx
15	2	λεμε... χειροτερα 	xxx
4	3	λεμε... πασοκ χειροτερα 	xxx
3	3	λεμε... θεμα χειροτερα 	xxx
15	2	holic retro 	xxx
6	3	holic ηχου retro 	xxx
4	3	holic αφιερωμενο retro 	xxx
9	3	holic καρδιας retro 	xxx
5	4	holic καρδιας ηχου retro 	xxx
3	5	holic λογου retro ηχου καρδιας 	xxx
15	1	ακη 	xxx
3	3	ακη μερας καθε 	xxx
5	2	ακη ηχου 	xxx
3	2	ακη αφιερωμενο 	xxx
3	2	ακη καρδιας 	xxx
4	2	ακη λογου 	xxx
3	3	ακη λογου ηχου 	xxx
4	3	ακη holic retro 	xxx
3	4	ακη holic ηχου retro 	xxx
10	1	θεατρο 	xxx
4	2	θεατρο ελλαδα 	xxx
3	3	θεατρο αθηνα ελλαδα 	xxx
14	1	2007 	xxx
11	2	2007 2008 	xxx
14	1	διαφημιση 	xxx
4	2	διαφημιση tv 	xxx
11	1	events 	xxx
14	1	προσωπα 	xxx
3	2	προσωπα blogs 	xxx
14	1	ζωη 	xxx
3	2	ζωη πολιτικη 	xxx
14	1	κυπρος 	xxx
12	1	microsoft 	xxx
3	2	microsoft software 	xxx
14	1	βιντεο 	xxx
14	1	συριζα 	xxx
8	2	συριζα πασοκ 	xxx
14	1	νοιαζει 	xxx
13	1	στοιχημα 	xxx
10	2	στοιχημα 2008 	xxx
13	1	γκρινια 	xxx
6	3	γκρινια μερας καθε 	xxx
3	2	γκρινια ηχου 	xxx
13	1	ιστοριες 	xxx
13	3	ομιλιεσ νεα τελευταια 	xxx
8	1	marketing 	xxx
3	2	marketing internet 	xxx
13	1	new 	xxx
3	2	new music 	xxx
4	2	new media 	xxx
3	3	new media internet 	xxx
3	3	new media blogs 	xxx
13	1	day 	xxx
13	1	ηπα 	xxx
7	2	ηπα πολιτικη 	xxx
7	2	ηπα ελλαδα 	xxx
3	2	ηπα ιστορια 	xxx
4	2	ηπα μακεδονια 	xxx
13	1	πληροφοριες 	xxx
12	1	χιουμορ 	xxx
13	1	πολιτισμος 	xxx
3	2	πολιτισμος πολιτικη 	xxx
3	2	πολιτισμος αρθρα 	xxx
9	1	windows 	xxx
3	2	windows software 	xxx
3	2	windows microsoft 	xxx
13	1	σινεμα 	xxx
3	2	σινεμα ποδοσφαιρο 	xxx
13	1	λογοτεχνια 	xxx
3	2	λογοτεχνια σινεμα 	xxx
13	1	α1 	xxx
12	1	google 	xxx
4	2	google internet 	xxx
4	2	google people 	xxx
3	3	google people internet 	xxx
13	1	ανθρωπινα 	xxx
11	2	ανθρωπινα δικαιωματα 	xxx
13	1	xblog 	xxx
4	2	xblog ελλαδα 	xxx
13	1	συμβουλες 	xxx
3	2	συμβουλες διαδικτυο 	xxx
12	1	θεσσαλονικης 	xxx
13	1	αναδημοσιευσεισ 	xxx
13	2	φιλοσοφιες σκυλο 	xxx
9	1	δεη 	xxx
6	2	δεη απεργια 	xxx
11	1	games 	xxx
3	2	games blog 	xxx
12	1	μπασκετ 	xxx
6	2	μπασκετ αρης 	xxx
12	1	hardware 	xxx
12	1	δελτια 	xxx
11	2	δελτια τυπου 	xxx
3	4	δελτια τυπου τελευταια νεα 	xxx
8	3	δελτια τυπου μμε 	xxx
12	1	ολυμπιακος 	xxx
3	2	ολυμπιακος ποδοσφαιρο 	xxx
12	1	tips 	xxx
12	1	υγεια 	xxx
12	1	oksikemia 	xxx
4	2	oksikemia media 	xxx
12	2	συμμαχια φιλελευθερη 	xxx
10	4	συμμαχια news φιλελευθερη πολιτικη 	xxx
7	5	συμμαχια news κοινωνια φιλελευθερη πολιτικη 	xxx
3	3	συμμαχια δικαιωματα φιλελευθερη 	xxx
9	3	συμμαχια οικονομια φιλελευθερη 	xxx
5	4	συμμαχια οικονομια ασφαλιστικο φιλελευθερη 	xxx
8	5	συμμαχια οικονομια news φιλελευθερη πολιτικη 	xxx
12	1	γεωργιου 	xxx
12	1	in 	xxx
12	1	εκκλησια 	xxx
3	2	εκκλησια κοινωνια 	xxx
12	1	τσιπρας 	xxx
5	2	τσιπρας πολιτικη 	xxx
5	2	τσιπρας πασοκ 	xxx
6	2	τσιπρας συριζα 	xxx
3	3	τσιπρας συριζα πασοκ 	xxx
12	1	εφημεριδες 	xxx
5	2	εφημεριδες θεμα 	xxx
7	2	εφημεριδες εγραψαν 	xxx
3	3	εφημεριδες εγραψαν θεμα 	xxx
12	1	εκ 	xxx
12	1	παιδεια 	xxx
12	1	πανεπιστημιο 	xxx
12	1	αλλαγη 	xxx
12	1	επικοινωνια 	xxx
12	1	δημοσ 	xxx
12	1	διδασκαλια 	xxx
3	2	διδασκαλια διαδικτυο 	xxx
7	2	διδασκαλια συμβουλες 	xxx
11	1	προβληματισμοι 	xxx
4	2	προβληματισμοι διδασκαλια 	xxx
11	1	μπλογκοσφαιρα 	xxx
11	2	ευρωλιγκα αρης 	xxx
5	3	ευρωλιγκα μπασκετ αρης 	xxx
11	1	blogroll 	xxx
6	1	vista 	xxx
5	2	vista windows 	xxx
11	1	νδ 	xxx
7	2	νδ πολιτικη 	xxx
9	2	νδ πασοκ 	xxx
6	3	νδ πασοκ πολιτικη 	xxx
3	3	νδ κκε πασοκ 	xxx
3	3	νδ συριζα πασοκ 	xxx
11	1	οτε 	xxx
11	1	παιδι 	xxx
11	1	εικαστικα 	xxx
10	2	εικαστικα εκθεσεις 	xxx
7	3	εικαστικα εκθεσεις ελλαδα 	xxx
5	4	εικαστικα εκθεσεις αθηνα ελλαδα 	xxx
3	3	εικαστικα κυπρος εκθεσεις 	xxx
11	2	ρινακη γεωργιου 	xxx
5	3	ρινακη ποιηση γεωργιου 	xxx
11	1	ανακοινωσεις 	xxx
11	1	περι 	xxx
11	1	ταινιες 	xxx
11	1	δημοσιογραφια 	xxx
3	2	δημοσιογραφια μμε 	xxx
3	2	δημοσιογραφια θεμα 	xxx
6	2	δημοσιογραφια απεργιες 	xxx
3	3	δημοσιογραφια απεργιες ασφαλιστικο 	xxx
3	3	δημοσιογραφια λεμε... χειροτερα 	xxx
11	1	ελληνικα 	xxx
11	3	mp3mania μιουzικα αλλαλουμ 	xxx
7	5	mp3mania φιλοσοφιες αλλαλουμ μιουzικα σκυλο 	xxx
10	1	architecture 	xxx
9	1	bloggers 	xxx
3	2	bloggers πολιτικη 	xxx
3	2	bloggers ελλαδα 	xxx
3	2	bloggers blogs 	xxx
3	2	bloggers social 	xxx
4	2	bloggers blogging 	xxx
8	1	mobile 	xxx
3	2	mobile windows 	xxx
10	1	tech 	xxx
4	2	tech hardware 	xxx
10	1	ιντερνετ 	xxx
10	1	σχολια 	xxx
5	2	σχολια blogroll 	xxx
10	1	βαλκανια 	xxx
7	2	βαλκανια ελλαδα 	xxx
5	3	βαλκανια μακεδονια ελλαδα 	xxx
6	3	βαλκανια αλβανια ελλαδα 	xxx
4	4	βαλκανια αλβανια μακεδονια ελλαδα 	xxx
10	1	συν 	xxx
4	2	συν πολιτικη 	xxx
4	2	συν κκε 	xxx
10	1	σχολιασμος 	xxx
10	1	youtube 	xxx
3	2	youtube διαδικτυο 	xxx
10	1	καπιταλισμος 	xxx
5	2	καπιταλισμος πολιτικη 	xxx
3	2	καπιταλισμος συν 	xxx
10	1	κειμενα 	xxx
10	1	αποψη 	xxx
10	1	γιορτες 	xxx
10	2	εσω εκ 	xxx
8	3	εσω music εκ 	xxx
4	4	εσω καθημερινοτητα εκ music 	xxx
10	1	δημητρης 	xxx
5	2	δημητρης by 	xxx
10	1	σκιτσα 	xxx
10	2	πδ 2008 	xxx
8	1	τμημα 	xxx
10	2	συνεχειες κριμα 	xxx
10	2	υμηττου δημοσ 	xxx
9	1	παναθηναικος 	xxx
4	2	παναθηναικος ολυμπιακος 	xxx
9	1	αληθειες 	xxx
9	1	personal 	xxx
8	1	τεχνες 	xxx
9	1	ταξιδια 	xxx
3	2	ταξιδια γενικα 	xxx
9	1	ανθρωποι 	xxx
9	2	minotavrs blog 	xxx
9	1	φωτογραφιεσ 	xxx
8	1	2.0 	xxx
6	2	2.0 web 	xxx
9	1	σκοπια 	xxx
5	2	σκοπια μακεδονια 	xxx
3	3	σκοπια αλβανια μακεδονια 	xxx
3	3	σκοπια ηπα μακεδονια 	xxx
8	1	επιχειρηματικοτητα 	xxx
9	1	networking 	xxx
8	2	networking social 	xxx
6	3	networking social internet 	xxx
9	1	φυση 	xxx
4	2	φυση περιβαλλον 	xxx
9	1	σπιτι 	xxx
9	1	greece 	xxx
4	2	greece internet 	xxx
4	2	greece people 	xxx
3	3	greece people internet 	xxx
3	3	greece google people 	xxx
8	1	history 	xxx
4	2	history people 	xxx
9	1	ανεκδοτα 	xxx
9	1	κυβερνηση 	xxx
4	2	κυβερνηση κοινωνια 	xxx
9	1	αριστερα 	xxx
3	2	αριστερα πολιτικη 	xxx
4	2	αριστερα πασοκ 	xxx
3	2	αριστερα ηπα 	xxx
9	1	πολη 	xxx
9	1	κωστας 	xxx
7	2	κωστας by 	xxx
9	1	εθνικα 	xxx
9	4	ανδρων 2008 2007 α1 	xxx
9	1	θεματα 	xxx
8	2	θεματα εθνικα 	xxx
5	3	θεματα εθνικα πολιτικη 	xxx
5	3	θεματα εθνικα αλβανια 	xxx
4	4	θεματα εθνικα αλβανια πολιτικη 	xxx
9	3	πανε πανεπιστημιο σκιτσα 	xxx
8	1	κριτικεσ 	xxx
8	1	αστρο 	xxx
7	2	αστρο ειδησεις 	xxx
8	1	photo 	xxx
8	1	ipod 	xxx
7	2	ipod iphone 	xxx
3	3	ipod freeware iphone 	xxx
8	1	ε.ε. 	xxx
3	2	ε.ε. διεθνη 	xxx
4	3	ε.ε. ηπα ελλαδα 	xxx
8	1	ανθρωπος 	xxx
8	1	φιλια 	xxx
8	1	παγκοσμιοποιηση 	xxx
8	1	real 	xxx
8	1	μουσεια 	xxx
6	2	μουσεια ελλαδα 	xxx
3	3	μουσεια εικαστικα εκθεσεις 	xxx
8	1	εταιρειες 	xxx
3	2	εταιρειες internet 	xxx
8	1	open 	xxx
6	1	facebook 	xxx
8	1	διαλογος 	xxx
8	2	επικαιροτητος σχολιασμος 	xxx
8	1	μουσικης 	xxx
8	1	lol 	xxx
8	1	books 	xxx
8	1	chaos 	xxx
8	1	σκηνοθετες 	xxx
6	1	on 	xxx
8	2	ανεμο πορδες 	xxx
8	1	σσστ...ακου... 	xxx
8	1	μεσα 	xxx
8	1	cinema 	xxx
8	2	field mine 	xxx
8	1	εκλογες 	xxx
3	2	εκλογες πολιτικη 	xxx
8	1	live 	xxx
8	1	φιλοσοφια 	xxx
8	1	φεστιβαλ 	xxx
5	2	φεστιβαλ θεσσαλονικης 	xxx
8	1	παοκ 	xxx
8	1	φτιαχνω 	xxx
5	2	φτιαχνω σπιτι 	xxx
8	3	δηλωσεισ νεα τελευταια 	xxx
7	4	δηλωσεισ ομιλιεσ νεα τελευταια 	xxx
8	4	μπιτς ντοντ χαβ ταμπελ 	xxx
8	1	pasok08 	xxx
6	2	pasok08 πολιτικη 	xxx
7	2	pasok08 πασοκ 	xxx
6	3	pasok08 συνεδριο πασοκ 	xxx
8	1	παραστασεις 	xxx
7	2	παραστασεις ελλαδα 	xxx
4	3	παραστασεις μουσικη ελλαδα 	xxx
4	3	παραστασεις αθηνα ελλαδα 	xxx
3	3	παραστασεις θεατρο ελλαδα 	xxx
8	1	γλυπτικη 	xxx
6	2	γλυπτικη αθηνα 	xxx
7	2	γλυπτικη art 	xxx
5	3	γλυπτικη art αθηνα 	xxx
8	1	rl 	xxx
7	1	θρησκεια 	xxx
3	2	θρησκεια πολιτικη 	xxx
7	1	αστυνομια 	xxx
7	1	σχεσεις 	xxx
6	1	εν 	xxx
7	1	with 	xxx
7	2	ενδιαφεροντος γενικου 	xxx
7	1	menu 	xxx
7	1	οικολογια 	xxx
3	2	οικολογια πολιτικη 	xxx
5	1	εγκληματα 	xxx
7	2	blogosfaira μπλογκοσφαιρα 	xxx
7	1	φωτογραφιες 	xxx
6	1	online 	xxx
7	1	politiki 	xxx
6	2	politiki πολιτικη 	xxx
7	1	γυναικων 	xxx
3	2	γυναικων α1 	xxx
7	1	εθνος 	xxx
7	1	κομματα 	xxx
6	2	κομματα πολιτικη 	xxx
7	1	συνεδρια 	xxx
4	2	συνεδρια εκδηλωσεις 	xxx
3	2	συνεδρια εκθεσεις 	xxx
7	2	crazy world 	xxx
3	3	crazy μουσικη world 	xxx
7	1	mme 	xxx
7	1	just 	xxx
7	1	μαλακιες 	xxx
7	1	ειδησεισ 	xxx
7	1	αφιερωμα 	xxx
4	2	αφιερωμα ηχου 	xxx
4	2	αφιερωμα λογου 	xxx
3	3	αφιερωμα λογου ηχου 	xxx
3	5	αφιερωμα holic ηχου καρδιας retro 	xxx
7	1	συγγραφεις 	xxx
7	1	αεκ 	xxx
3	2	αεκ ποδοσφαιρο 	xxx
3	2	αεκ αρης 	xxx
4	2	αεκ ολυμπιακος 	xxx
3	3	αεκ παναθηναικος ολυμπιακος 	xxx
7	2	fractal chaos 	xxx
4	3	fractal people chaos 	xxx
3	3	fractal greece chaos 	xxx
4	3	fractal history chaos 	xxx
7	1	επιστημη 	xxx
7	1	μουσικες 	xxx
7	1	fun 	xxx
7	1	παιχνιδια 	xxx
7	1	nature 	xxx
3	2	nature people 	xxx
7	1	city 	xxx
7	2	νικολαοσ αγιοσ 	xxx
7	1	oraelladas 	xxx
3	2	oraelladas πολιτικη 	xxx
3	2	oraelladas κοινωνια 	xxx
3	2	oraelladas blog 	xxx
7	1	συνασπισμος 	xxx
6	2	συνασπισμος πασοκ 	xxx
4	3	συνασπισμος παπανδρεου πασοκ 	xxx
3	4	συνασπισμος παπανδρεου συνεδριο πασοκ 	xxx
4	2	συνασπισμος τσιπρας 	xxx
3	3	συνασπισμος τσιπρας πασοκ 	xxx
7	1	πατρα 	xxx
7	1	σοβαρα 	xxx
7	2	μοντελα νεα 	xxx
7	3	8ο πασοκ συνεδριο 	xxx
4	4	8ο παπανδρεου πασοκ συνεδριο 	xxx
7	1	σημειωσεις 	xxx
7	1	fashion 	xxx
7	1	10ο 	xxx
7	1	εφημεριδα 	xxx
7	2	κατηγορια χωρις 	xxx
7	1	πανεπιστημιακα 	xxx
7	2	βαχ αχ 	xxx
7	1	παλια 	xxx
6	2	παλια νεα 	xxx
7	1	η.π.α. 	xxx
6	1	photos 	xxx
3	2	photos funny 	xxx
6	1	chris 	xxx
6	1	technological 	xxx
4	2	technological internet 	xxx
3	3	technological software internet 	xxx
6	1	δικα 	xxx
3	2	δικα ιστοριες 	xxx
6	1	γη 	xxx
6	1	μακεδονικο 	xxx
5	2	μακεδονικο πολιτικη 	xxx
5	1	update 	xxx
3	2	update software 	xxx
6	1	american 	xxx
5	1	pc 	xxx
3	3	pc tech hardware 	xxx
6	1	poesia 	xxx
5	2	poesia ποιηση 	xxx
6	1	chat 	xxx
6	2	section greek 	xxx
3	3	section δικαιωματα greek 	xxx
6	1	ημερας 	xxx
5	1	technology 	xxx
6	2	series tv 	xxx
4	3	series movies tv 	xxx
6	1	θεωρια 	xxx
6	1	νεολαια 	xxx
6	5	mauros εργατικα kyknos φωτογραφιεσ maypos 	xxx
6	1	αναδημοσιευση 	xxx
6	2	estate real 	xxx
3	3	estate architecture real 	xxx
6	1	κεντρο 	xxx
4	2	κεντρο ελλαδα 	xxx
3	3	κεντρο εικαστικα εκθεσεις 	xxx
6	1	ιδρυμα 	xxx
4	2	ιδρυμα ελλαδα 	xxx
3	3	ιδρυμα εικαστικα εκθεσεις 	xxx
6	2	συναυλιες μουσικη 	xxx
5	4	συναυλιες αθηνα ελλαδα μουσικη 	xxx
6	1	athens 	xxx
6	3	wallpaper freeware wallpapers 	xxx
4	4	wallpaper apple wallpapers freeware 	xxx
6	1	general 	xxx
6	2	μεσημβρινες μαλακιες 	xxx
6	1	hellas 	xxx
5	1	παγκοσμια 	xxx
5	1	μερα 	xxx
6	1	so 	xxx
6	1	ελληνικο 	xxx
4	2	ελληνικο τραγουδι 	xxx
3	4	ελληνικο ελληνικη ποιηση τραγουδι 	xxx
6	1	sex 	xxx
6	1	snow 	xxx
3	2	snow events 	xxx
6	1	παρατηρησεις 	xxx
6	1	εμεις 	xxx
4	2	εμεις αυτισμος 	xxx
6	3	ατιμη κοινωνια thessaloniki 	xxx
5	4	ατιμη politics thessaloniki κοινωνια 	xxx
6	1	talk 	xxx
6	1	gay 	xxx
5	1	ταξιδι 	xxx
5	1	travel 	xxx
3	1	ikea 	xxx
6	1	απ 	xxx
6	1	φυτα 	xxx
6	1	μουσειο 	xxx
3	3	μουσειο εικαστικα εκθεσεις 	xxx
5	2	μουσειο μουσεια 	xxx
4	4	μουσειο μουσεια αθηνα ελλαδα 	xxx
3	3	μουσειο μουσεια εκδηλωσεις 	xxx
6	1	συνδικαλιστικα 	xxx
6	1	κριτικη 	xxx
6	1	πρωτοβουλιες 	xxx
3	2	πρωτοβουλιες θεμα 	xxx
4	2	πρωτοβουλιες προτασεις 	xxx
3	3	πρωτοβουλιες δημοσιογραφια απεργιες 	xxx
6	1	αστρολογια 	xxx
3	2	λιβαδειας εκδηλωσεις 	xxx
6	1	εκεβι 	xxx
5	2	εκεβι ποιηση 	xxx
6	1	γιαννησ 	xxx
6	1	δημοσια 	xxx
5	1	αθλητισμος 	xxx
5	1	sport 	xxx
5	1	πρωταθλημα 	xxx
3	2	πρωταθλημα ποδοσφαιρο 	xxx
5	3	προσπαθεia 2008 στοιχημα 	xxx
5	1	anime 	xxx
4	1	time 	xxx
5	1	miscellaneous 	xxx
3	2	miscellaneous technological 	xxx
5	2	αγαπητο ημερολογιο 	xxx
5	1	bulgaria 	xxx
5	1	αρχη 	xxx
5	1	γενεων 	xxx
3	2	γενεων κοινωνια 	xxx
4	2	γενεων ασφαλιστικο 	xxx
3	2	γενεων σχεσεις 	xxx
5	1	dvd 	xxx
3	2	dvd ταινιες 	xxx
4	1	samsung 	xxx
3	2	samsung τεχνολογια 	xxx
5	1	idol 	xxx
3	2	idol american 	xxx
5	1	gossip 	xxx
5	2	γελοιογραφια ημερας 	xxx
4	1	νικηφορος 	xxx
5	1	ωρα 	xxx
5	1	international 	xxx
5	2	ευρωπαικη πολιτικη 	xxx
5	2	ενωση ελλαδα 	xxx
5	2	κοσοβο βαλκανια 	xxx
5	1	μεταναστες 	xxx
5	1	σερβια 	xxx
4	2	σερβια αλβανια 	xxx
5	2	κρητη ελλαδα 	xxx
5	1	καινοτομια 	xxx
3	2	καινοτομια τεχνολογια 	xxx
5	1	comments 	xxx
3	2	comments ελλαδα 	xxx
5	1	eurovision 	xxx
5	1	κοινωνικος 	xxx
5	1	ανδρεας 	xxx
5	4	μεγαρο ελλαδα μουσικη μουσικης 	xxx
3	5	μεγαρο παραστασεις ελλαδα μουσικη μουσικης 	xxx
5	1	φιλοι 	xxx
5	1	βορβορυγμοι 	xxx
5	1	reviews 	xxx
5	1	κολπα 	xxx
5	1	προγνωστικα 	xxx
5	1	τουρκια 	xxx
5	1	πανιωνιος 	xxx
5	1	ασφαλεια 	xxx
3	2	ασφαλεια internet 	xxx
5	1	δημος 	xxx
5	1	sky 	xxx
5	1	νεες 	xxx
5	1	science 	xxx
5	1	computing 	xxx
4	4	computing fractal art chaos 	xxx
5	1	κνε 	xxx
3	2	κνε κκε 	xxx
5	1	αναμεταδοσεις 	xxx
3	2	αναμεταδοσεις internet 	xxx
5	4	εγγραφου νεα τελευταια ειδοσ 	xxx
3	5	εγγραφου αρθρα ειδοσ νεα τελευταια 	xxx
5	1	κοσμου 	xxx
5	1	shopping 	xxx
5	1	πολιτων 	xxx
3	2	πολιτων κοινωνια 	xxx
5	1	δημοσιευσεις 	xxx
5	3	μεγαλοι ρεμπετες αντιγραφεας 	xxx
5	1	βιβλιοθηκη 	xxx
3	2	βιβλιοθηκη εκδηλωσεις 	xxx
5	1	think 	xxx
5	2	can so 	xxx
5	3	φιλων ανεκδοτα αναγνωστων 	xxx
5	2	προσυνεδριακος διαλογος 	xxx
3	3	προσυνεδριακος πασοκ διαλογος 	xxx
4	3	προσυνεδριακος συνεδριο διαλογος 	xxx
3	4	προσυνεδριακος συνεδριο 2008 διαλογος 	xxx
5	1	πα.σο.κ 	xxx
5	1	magazine 	xxx
3	2	magazine ovi 	xxx
5	1	βια 	xxx
5	2	μηνυμα αποψη 	xxx
5	1	εκπαιδευτικα 	xxx
3	2	εκπαιδευτικα αυτισμος 	xxx
5	2	φριντα ακη 	xxx
5	2	γενικεσ ειδησεισ 	xxx
5	1	φωτο 	xxx
3	3	φωτο ρινακη γεωργιου 	xxx
5	2	κοντου ημερολογιο 	xxx
5	1	νικος 	xxx
5	1	podcast 	xxx
5	3	cine tv talk 	xxx
5	1	χρονος 	xxx
5	1	βιβλιο 	xxx
3	3	βιβλιο αθηνα ελλαδα 	xxx
5	1	βιβλιοθηκες 	xxx
3	2	βιβλιοθηκες βιβλιοθηκη 	xxx
5	1	γαμοσ 	xxx
5	1	εργασια 	xxx
5	1	αγαπησα 	xxx
5	1	fest 	xxx
5	1	various 	xxx
5	1	λιστες 	xxx
5	1	υπουργειο 	xxx
5	2	επιστημης επικοινωνια 	xxx
3	4	επιστημης συνεδρια εκδηλωσεις επικοινωνια 	xxx
5	1	νομος 	xxx
4	2	νομος θεσσαλονικης 	xxx
5	2	διακυβερνηση νεα 	xxx
5	1	newspapers 	xxx
4	3	newspapers people news 	xxx
3	4	newspapers people internet news 	xxx
3	4	newspapers people blogging news 	xxx
5	1	παλαιστινη 	xxx
5	1	super 	xxx
4	1	εικονα 	xxx
5	1	rant 	xxx
5	1	αξιοπρεπεια 	xxx
4	1	sexy 	xxx
5	1	ειπατε 	xxx
5	1	ωραια 	xxx
5	3	μανιασ τμημα φοβιασ 	xxx
5	2	τεχνολ επιστ 	xxx
3	3	τεχνολ κοινωνια επιστ 	xxx
4	1	μοδα 	xxx
5	2	πρωτο θεμα 	xxx
5	1	θρακη 	xxx
5	2	πρωταγωνιστησ δημοτησ 	xxx
4	4	πρωταγωνιστησ υμηττου δημοτησ δημοσ 	xxx
5	2	καλτσασ γιαννησ 	xxx
4	4	καλτσασ πρωταγωνιστησ γιαννησ δημοτησ 	xxx
4	1	diamonds 	xxx
4	2	uli chris 	xxx
4	1	3d 	xxx
3	1	vodafone 	xxx
4	2	πλανητης γη 	xxx
4	1	λογος 	xxx
4	1	ανθρωπους 	xxx
4	1	release 	xxx
3	2	release new 	xxx
4	1	notebook 	xxx
3	1	rss 	xxx
4	1	lost 	xxx
4	1	security 	xxx
4	2	chit chat 	xxx
4	3	καραμανλης νεα δημοκρατια 	xxx
4	2	κεντρωτησ ποιηση 	xxx
4	2	ισπανοφωνη ποιηση 	xxx
4	1	ρικιστικα 	xxx
3	2	ρικιστικα καθημερινα 	xxx
3	2	ρικιστικα αυτισμος 	xxx
4	1	cd 	xxx
3	2	βρεττακος νικηφορος 	xxx
4	1	συνεντευξη 	xxx
4	1	σουρεαλ 	xxx
4	3	ματι μπλογκοσφαιρα blogosfaira 	xxx
4	1	free 	xxx
4	3	εκδρομες ταξιδια φωτογραφιες 	xxx
4	1	blgr. 	xxx
4	1	φαντασια 	xxx
4	1	πολεμος 	xxx
3	4	πολεμος politiki πολιτικη διεθνη 	xxx
4	1	παο 	xxx
3	2	παο ποδοσφαιρο 	xxx
4	1	τηλεοραση 	xxx
4	1	πολιτιστικα 	xxx
4	1	οπισθοδρομικοτητα 	xxx
4	1	ακυρα 	xxx
4	1	κακοποιηση 	xxx
4	1	εργασιακα 	xxx
4	1	wtf 	xxx
4	1	fyrom 	xxx
4	3	σκυλοσπιταρονες real estate 	xxx
4	4	pack windows vista service 	xxx
4	1	up 	xxx
4	1	νεοι 	xxx
4	1	κρατος 	xxx
4	2	συνταξεις ασφαλιστικο 	xxx
4	3	συνταξη πολιτικη ασφαλιστικο 	xxx
4	3	macosx software freeware 	xxx
4	1	αρχιτεκτονικη 	xxx
4	5	αθηνων ελλαδα μουσικη μουσικης μεγαρο 	xxx
4	1	club 	xxx
4	1	pix 	xxx
4	1	death 	xxx
4	1	diary 	xxx
4	1	λεβαδειακος 	xxx
3	2	λεβαδειακος αρης 	xxx
4	2	νικη αρης 	xxx
4	1	νεο 	xxx
3	1	παιδικη 	xxx
3	1	ray 	xxx
3	1	arthur 	xxx
4	2	π.α.με εργατικα 	xxx
4	2	οπορτουνισμος συν 	xxx
4	3	μετωπο διεθνη αντιιμπεριαλιστικο 	xxx
4	1	δια 	xxx
3	2	δια τυπου 	xxx
4	1	famous 	xxx
4	1	animals 	xxx
3	2	animals famous 	xxx
4	2	τηλεπικοινωνιες οτε 	xxx
4	3	sp1 windows vista 	xxx
3	5	sp1 pack windows vista service 	xxx
4	3	αγορεσ κοσμου shopping 	xxx
4	2	σχεδιασμοσ design 	xxx
4	4	mbi ρεμπετες αντιγραφεας μεγαλοι 	xxx
4	1	οικολογιο 	xxx
4	4	niaou so think can 	xxx
4	1	interactive 	xxx
3	2	interactive marketing 	xxx
4	1	καβαλας 	xxx
4	1	αποκριες 	xxx
4	1	καβαλα 	xxx
3	2	καβαλα περιβαλλον 	xxx
4	1	δημοσκοπησεις 	xxx
4	1	χαβαλες 	xxx
4	2	ιταλικο τραγουδι 	xxx
4	1	designers 	xxx
4	1	παιξε 	xxx
4	1	αλλων 	xxx
4	3	μηνιας ηχου αρχι 	xxx
4	1	αγαπη 	xxx
4	2	μαζικης μεσα 	xxx
4	1	ρακοσυλλεκτης 	xxx
4	1	ερευνα 	xxx
4	1	μπλογκ 	xxx
4	1	τεχνη 	xxx
4	3	lover by city 	xxx
4	2	μαρουλακι by 	xxx
3	4	μαρουλακι lover by city 	xxx
4	2	ποτακι by 	xxx
4	1	οικολογικα 	xxx
4	1	τριανταφυλλοπουλος 	xxx
4	1	βενιζελος 	xxx
3	3	βενιζελος παπανδρεου πασοκ 	xxx
4	1	συναισθηματα 	xxx
4	3	προορισμοι ελλαδα ταξιδι 	xxx
4	1	βασιλης 	xxx
4	1	κουλτουρα 	xxx
4	1	εκκλησιαστικα 	xxx
4	1	σπιτια 	xxx
4	2	ομοφυλων γαμοσ 	xxx
3	1	οτα 	xxx
4	1	γαμος 	xxx
3	1	ομαδες 	xxx
4	3	τσαντες πλαστικα ναυλον 	xxx
4	1	πολυ 	xxx
4	1	τραγουδια 	xxx
3	5	τραγουδια πολυ απ αγαπησα ανθρωπους 	xxx
4	1	χειμαρασ 	xxx
3	2	ντοκιμαντερ φεστιβαλ 	xxx
4	1	ελευθερια 	xxx
3	2	ελευθερια λογου 	xxx
4	1	γυναικες 	xxx
4	1	theme 	xxx
4	1	βομβιδια 	xxx
3	2	βομβιδια πολιτικα 	xxx
4	1	film 	xxx
4	1	σκουπιδια 	xxx
4	1	ασυναρτησιες 	xxx
4	2	ατομικα δικαιωματα 	xxx
3	3	ατομικα εκκλησια δικαιωματα 	xxx
4	1	τουρνουα 	xxx
4	1	ανακυκλωση 	xxx
4	1	subprime 	xxx
3	1	bear 	xxx
4	1	market 	xxx
3	1	τηλεφωνια 	xxx
4	1	διασκεδαστικα 	xxx
4	1	marfin 	xxx
4	1	digital 	xxx
4	1	report 	xxx
3	2	report live 	xxx
4	1	b2b 	xxx
4	1	bookcrossing 	xxx
4	2	εξωφρενικες λιστες 	xxx
4	1	κατρακυλα 	xxx
4	2	letteratura poesia 	xxx
3	3	letteratura ποιηση poesia 	xxx
4	1	ferrari 	xxx
4	3	doc 10ο fest 	xxx
4	1	περιοδικα 	xxx
4	1	ενεργεια 	xxx
4	1	formula 	xxx
4	5	ηχοσ νεα τελευταια ομιλιεσ δηλωσεισ 	xxx
4	1	ιατρικη 	xxx
4	1	εμμανουηλ 	xxx
4	2	week fashion 	xxx
4	4	δυτικα αθηνα art γλυπτικη 	xxx
4	1	φοιτητες 	xxx
4	1	τρεχοντα 	xxx
4	3	πυρκαλ δημοσ υμηττου 	xxx
4	2	τεχνολογιες νεες 	xxx
3	3	τεχνολογιες διδασκαλια νεες 	xxx
4	3	γεια πατρα ωραια 	xxx
4	1	διεθνες 	xxx
4	1	εε 	xxx
4	1	combat 	xxx
3	2	γυμνες αληθειες 	xxx
3	1	καλλιτεχνικο 	xxx
3	2	σκακιστικη ιστορια 	xxx
3	1	trends 	xxx
3	1	lg 	xxx
3	1	reality 	xxx
3	1	de 	xxx
3	1	επιστημες 	xxx
3	1	ανατολη 	xxx
3	3	headlines blogging people 	xxx
3	1	προσωπικο... 	xxx
3	2	αητητη. ηλιθιοτητα 	xxx
3	2	vita ζωη 	xxx
3	3	os apple mac 	xxx
3	1	evenements 	xxx
3	3	presentations video cd 	xxx
3	1	γυναικα 	xxx
3	3	bubbles μπλογκοσφαιρα blogosfaira 	xxx
3	1	θανατος 	xxx
3	4	σωμα μπλογκοσφαιρα blogosfaira κορμι 	xxx
3	3	ψυχη μπλογκοσφαιρα blogosfaira 	xxx
3	1	computers 	xxx
3	1	culture 	xxx
3	1	euroleague 	xxx
3	3	λιετουβος αρης ευρωλιγκα 	xxx
3	3	προκριση αρης ευρωλιγκα 	xxx
3	1	νομαρχια 	xxx
3	3	οδοιπορικο πολιτικη politiki 	xxx
3	1	story 	xxx
3	1	10 	xxx
3	3	αποτυχια 2008 στοιχημα 	xxx
3	1	that 	xxx
3	4	rc1 software wordpress 2.5 	xxx
3	1	τεχνων 	xxx
3	1	16 	xxx
3	3	φιλελευθερου κοινωνια αποψεις 	xxx
3	4	start open up coffee 	xxx
3	1	παραμυθια 	xxx
3	1	michael 	xxx
3	2	ημερολογιου ημερες 	xxx
3	1	φυσικη 	xxx
3	1	machine 	xxx
3	1	ξεπουλημα 	xxx
3	1	δραση 	xxx
3	1	συνταγες 	xxx
3	1	this 	xxx
3	2	album reviews 	xxx
3	1	black 	xxx
3	1	κοινωνικοπολιτικα 	xxx
3	1	star 	xxx
3	1	goodies 	xxx
3	1	crap 	xxx
3	2	deal with 	xxx
3	3	ταου αρης ευρωλιγκα 	xxx
3	1	αελ 	xxx
3	2	ουεφα αρης 	xxx
3	1	μαρουσι 	xxx
3	2	μπαγεβιτς αρης 	xxx
3	1	κινα 	xxx
3	1	yahoo 	xxx
3	1	intel 	xxx
3	1	sequel 	xxx
3	3	traditional chaos fractal 	xxx
3	1	εντυπωσιακα 	xxx
3	1	rock 	xxx
3	5	room in with sky diamonds 	xxx
3	1	albums 	xxx
3	1	τραπεζες 	xxx
3	4	κοινοβουλευτικα μμε τυπου δελτια 	xxx
3	1	προιοντα 	xxx
3	1	nvidia 	xxx
3	1	home 	xxx
3	1	links 	xxx
3	1	me.vs.world 	xxx
3	1	τεκμηριωσεις 	xxx
3	1	info 	xxx
3	1	κατα 	xxx
3	1	ρατσισμος 	xxx
3	1	παραδεισος 	xxx
3	1	δημοσιευματα 	xxx
3	2	κυριακος κυρ 	xxx
3	1	λιθανθρακας 	xxx
3	4	κοεσ συνεδριο διαλογος προσυνεδριακος 	xxx
3	1	θεσεις 	xxx
3	1	forum 	xxx
3	1	posts 	xxx
3	3	ναπολιτανικο τραγουδι ιταλικο 	xxx
3	1	mind 	xxx
3	2	graphic design 	xxx
3	1	ες 	xxx
3	1	πλακα 	xxx
3	1	διαφορες 	xxx
3	1	συνεντευξεις 	xxx
3	1	asides 	xxx
3	1	linux 	xxx
3	3	αλλοι αυτισμος εμεις 	xxx
3	2	πανηγυρια γιορτες 	xxx
3	1	robert 	xxx
3	1	οικογενειακα 	xxx
3	2	source open 	xxx
3	2	spring 2008 	xxx
3	1	επιχειρειν 	xxx
3	1	σχολιο 	xxx
3	1	our 	xxx
3	2	οσφπ ποδοσφαιρο 	xxx
3	4	κοροιδια πολιτικη πασοκ νδ 	xxx
3	3	κερδη καπιταλισμος καπιταλιστικα 	xxx
3	1	john 	xxx
3	3	καραμανλησ νεα δημοκρατια 	xxx
3	3	αφορισμοι γεωργιου ρινακη 	xxx
3	2	ντοκυμανταιρ βιντεο 	xxx
3	2	γαλιλαιος by 	xxx
3	1	νοσταλγιες 	xxx
3	1	συνθηματα 	xxx
3	1	εκπαιδευση 	xxx
3	1	δημοτικη 	xxx
3	1	καλυβα 	xxx
3	1	αταξινομητα 	xxx
3	1	δαση 	xxx
3	1	αγωνες 	xxx
3	1	δικαιοσυνη 	xxx
3	1	μνημη 	xxx
3	1	καταστροφες 	xxx
3	1	akouseto.gr 	xxx
3	2	air macbook 	xxx
3	1	κινητα 	xxx
3	1	επιχειρησεισ 	xxx
3	1	δημου 	xxx
3	1	εμπορευματα 	xxx
3	2	φυγουμε κουλτουρα 	xxx
3	3	μονον... περι μουσικης 	xxx
3	1	γεγονοτα 	xxx
3	2	αναλεκτα εκκλησιαστικα 	xxx
3	3	αληθινα κολπα σπιτια 	xxx
3	1	επικαιρα 	xxx
3	1	5χ5 	xxx
3	1	στηλη 	xxx
3	3	ipodgr.com iphone ipod 	xxx
3	1	one 	xxx
3	1	videopost 	xxx
3	1	love 	xxx
3	4	painting people chaos fractal 	xxx
3	2	sofia bulgaria 	xxx
3	1	αλληλεγγυη 	xxx
3	1	συμβιωσης 	xxx
3	2	τσιφης βοιωτια 	xxx
3	1	ιερες 	xxx
3	1	γραμμα 	xxx
3	1	labels 	xxx
3	1	television 	xxx
3	5	top. διαφορα various blgr. yiota 	xxx
3	1	παρουσιαση 	xxx
3	1	εργασιας 	xxx
3	1	προληψη 	xxx
3	1	υγειας 	xxx
3	2	noir film 	xxx
3	3	εναλλακτικα κοινωνικα πολιτισμος 	xxx
3	4	θεολογια πολιτισμος φιλοσοφια διαπολιτισμικα 	xxx
3	1	networks 	xxx
3	1	γελιο 	xxx
3	4	τροφεσ σπιτι φτιαχνω συντηρω 	xxx
3	2	γαλακτοκομικα φτιαχνω 	xxx
3	1	αποδρασεις 	xxx
3	1	ακριβεια 	xxx
3	2	μουσικα βιντεο 	xxx
3	1	φωτονια 	xxx
3	1	καρναβαλι 	xxx
3	1	ενδιαφεροντα 	xxx
3	1	sites 	xxx
3	1	ποιηματα 	xxx
3	3	δεπαμαν αγιοσ νικολαοσ 	xxx
3	1	rights 	xxx
3	2	εξωτερικου τουρνουα 	xxx
3	1	θεσσαλονικιωτικα 	xxx
3	1	ερευνες 	xxx
3	1	νικολας 	xxx
3	1	ομορφια 	xxx
3	1	υφεση 	xxx
3	1	ιρλανδια 	xxx
3	1	politique 	xxx
3	1	hp 	xxx
3	1	flash 	xxx
3	4	telekom οτε marfin deutsche 	xxx
3	1	προγραμμα 	xxx
3	2	cassini enceladus 	xxx
3	1	μπλογκοπαιχνιδα 	xxx
3	1	πανεπιστημια 	xxx
3	2	εφη ταδε 	xxx
3	1	καρδια 	xxx
3	1	αυτοκινητα 	xxx
3	1	ηθικη 	xxx
3	1	καφροκουλτουρα 	xxx
3	2	νυχτες καμμενες 	xxx
3	1	poem 	xxx
3	1	gaydar 	xxx
3	1	αντισταση 	xxx
3	2	κονομα χοντρη 	xxx
3	1	δυο 	xxx
3	1	from 	xxx
3	1	neolaia.gr 	xxx
3	4	ντοκυμαντερ θεσσαλονικης φεστιβαλ 10ο 	xxx
3	3	περιφερειας ενεργεια δρασεις 	xxx
3	1	arts 	xxx
3	1	ακροδεξια 	xxx
3	2	καθεστωσ εφημεριδα 	xxx
3	1	παρελαση 	xxx
3	2	τv κινηματογραφος 	xxx
3	1	ιδεεσ 	xxx
3	2	πορευομεθα αποψη 	xxx
3	1	βαγγελης 	xxx
3	1	γιαννης 	xxx
3	2	moods everyday 	xxx
3	1	σεμιναρια 	xxx
3	1	ρθε 	xxx
3	3	αναστασιαδης θεμα πρωτο 	xxx
3	4	μπομπολας θεμα πρωτο τριανταφυλλοπουλος 	xxx
3	2	εκδηλωσεισ mabrida 	xxx
3	1	ανασκελο 	xxx
3	2	ανεμων... περι 	xxx
3	1	μπλογκοπαιγνια 	xxx
3	3	σπηλαιων music ανθρωπος 	xxx
3	1	νοσταλγικα 	xxx
3	1	αφρικη 	xxx
3	1	πειραμα 	xxx
3	1	τεχνης 	xxx
3	1	μυθιστορημα 	xxx
3	1	μαρτιου 	xxx
3	2	διοικηση δημοσια 	xxx
3	1	radio 	xxx
3	1	σατιρα 	xxx
3	2	development web 	xxx
3	1	trailers 	xxx
3	1	uefa 	xxx
3	2	λευκωσια κυπρος 	xxx
3	1	freecycle 	xxx
\.
--create index xo__buzz_recent_tags on xo.xo__buzz_recent_tags using gist (itemset_ts_vector);
--create index xo__buzz_itemset_occ__idx on xo.xo__buzz_recent_tags(occurrence);
update xo.xo__buzz_recent_tags set itemset_ts_vector=to_tsvector('simple',itemset_tags)||to_tsvector('xo.xo__ts_cfg_greek',itemset_tags);
end;
vacuum full analyze xo.xo__buzz_recent_tags;

<master>
<property name=title>Προσωπικός Χώρος: @full_name@</property>

<table width=100% cellpadding=0 cellspacing=0 border=0><tr><td width=70% valign=top>
@context_bar@
<h2>@full_name@</h2>
<p>
<table border=0 cellspacing=0 cellpadding=0>
  <tr>
    <td>&nbsp;</td>
      <multiple name="tabs">
        <if @tabs.key@ eq @tab@>
          <td bgcolor=333366>&nbsp;<font color="#eeeeff">@tabs.name@</font>&nbsp;</td>
        </if>
        <else>
          <td>&nbsp;<a href="@tabs.url@" class=t>@tabs.name@</a>&nbsp;</td>
        </else>
      </multiple>
    <td width="100%">&nbsp;</td>
  </tr>
  <tr bgcolor=333366>
    <td colspan="<%=[expr {${tabs:rowcount}*2+2}]%>">
      <table border=0 cellspacing=0 cellpadding=0>
        <tr>
          <td height=5>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>

<if @tab@ eq "home">
<table width=100% border=0 cellpadding=2 cellspacing=0><tr bgcolor=9999cc>
<td>&nbsp;<font size=4><b>
Home
</b></font><font size=2> - Τελευταία επίσκεψη στις <%= [util_AnsiDatetoPrettyDate @second_to_last_visit@]%></font>
</td></tr></table>

<table cellpadding=5 cellspacing=0 border=0><tr><td width=70% valign=top>

<table width=100% cellpadding=4 cellspacing=0 border=0><tr bgcolor=ffffff><td>

<h4>Τι λέμε στους άλλους χρήστες για σένα</h4>
Κατά κανόνα, προσδιορίζουμε το περιεχόμενο που έχεις δημοσιεύσει
με το όνομα σου. Στην προσπάθεια μας να σε προστατεύσουμε
από απαράκλητο email, δείχνουμε το email σου
μόνο στους εγγεγραμμένους χρήστες. Πλήρης απόκρυψη
δεδομένων είναι τεχνικά εφικτή αλλά ένα σημαντικό στοιχείο
μιας διαδικτυακής κοινότητας είναι ότι οι άνθρωποι μπορούν να
μάθουν ο ένας από τον άλλο. Γι αυτό το λόγο προσπαθούμε να κάνουμε
δυνατό για τους χρήστες με κοινά ενδιαφέροντα να επικοινωνήσουν
μεταξύ τους. 

<p>Αν θέλεις να δείς τι βλέπουν οι άλλοι χρήστες 
για σένα, επισκέψου
<a href="@profile_url@">το δημόσιο προφίλ σου</a>.

<p>

<h4>Προσωπικά Στοιχεία</h4>

<ul>
<li>Όνομα: @full_name@
<li>Διεύθυνση email: @email@
<li>Προσωπική Ιστοσελίδα:  <a target=new_window href="@url@">@url@</a>
<li>Ψευδώνυμο: @screen_name@
<li>Βιογραφία: @bio@
<p>
(<a href="/my/basic-info-update">update</a>)
</ul>


</td></tr></table>


</td><td width=30% valign=top>

<table width=100% cellpadding=0 cellspacing=5 border=0><tr><td bgcolor=cccccc>

<table width=100% cellpadding=2 cellspacing=1 border=0>
<tr bgcolor=ccccff><td align=center>
<b>Αυτοδιοίκηση</b>
</td></tr><tr bgcolor=ffffff><td>

- <a href="/register/logout">Log out</a>
<p>
- <a href="/my/password-update">Αλλαγή κωδικού</a>
<p>
- <a href="/my/notifications">Ειδοποιήσεις</a>

</td></tr></table>

</td></tr><tr><td bgcolor=cccccc>
<table width=100% cellpadding=2 cellspacing=1 border=0>
<tr bgcolor=ccccff><td align=center>
<b>Υπηρεσίες</b>
</td></tr><tr bgcolor=ffffff><td>

- Ημερολόγιο καταστρώματος
<p>
- <a href=bookmarks/>Σελιδοδείκτες</a>

</td></tr></table>

</td></tr></table>

</td></tr></table>

</td></tr></table>
</if>



<if @tab@ eq "channels">
<table width=100% border=0 cellpadding=2 cellspacing=0><tr bgcolor=9999cc>
<td>&nbsp;<font size=4><b>Σταθμοί Πληροφόρησης</b></font></td>
</tr>
</table>
<p>
<br>
<p>
<table width=80% align=center cellspacing=0 cellpadding=0 border=1><tr><td>
<p>
<blockquote>
Αυτή η υπηρεσία είναι υπο κατασκευή και
μπορείς να τη φανταστείς σαν μια διαδικτυακή
μορφή zapping (όπως κάνεις και με τους τηλεοπτικούς σταθμούς).
Οι σταθμοί πληροφόρησης θα περιέχουν
εφήμερους σελιδοδείκτες για ειδήσεις, άρθρα, κοκ από εκατοντάδες 
άλλες διαδικτυακές περιοχές όπως
για παράδειγμα το <a href=http://www.cnn.com>CNN</a>
ή το <a href=http://www.slashdot.com>Slashdot</a>.
<p>
Αυτό σημαίνει ότι θα μπορείς να βλέπεις συνοπτικά
οτιδήποτε καινούριο δημοσιεύεται τη στιγμή που δημοσιεύεται
για τους σταθμούς που παρακολουθείς.
Η ημερομηνία διάθεσης της υπηρεσίας θα ανακοινωθεί
σύντομα (αυτό σημαίνει πολύ σύντομα για όσους
από εσάς δεν παρακολουθούσατε την εξέλιξη της
περιοχής την τελευταία εβδομάδα). Η υλοποίηση
θα γίνει σε δύο φάσεις: Η πρώτη φάση θα περιλαμβάνει
σταθμούς που θα προκαθορίσουν οι διαχειριστές της
περιοχής. Στη δεύτερη φάση θα παρέχεται η δυνατότητα
να επιλέξεις σταθμούς της προτίμησης σου. Αν έχεις 
οποιοσδήποτε ερωτήσεις μπορείς να τις απευθύνεις
στα <a href=/forums>Φόρουμς</a>.
<p>
-- <a href=/~2422>Νεόφυτος Δημητρίου</a>, 22 Φεβρουαρίου 2002
</blockquote>
<p>
</td></tr>

</if>

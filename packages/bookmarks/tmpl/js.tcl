script -language javascript {
    c {

function check(func) {
var i;
for (i=0; document.bookmarks_form.elements[i]; i++) {
if (document.bookmarks_form.elements[i].type == "checkbox" &&
(document.bookmarks_form.elements[i].name == "bid" || document.bookmarks_form.elements[i].name == "fid") && 
document.bookmarks_form.elements[i].checked == true) {
  if (func==0) {
  return confirm("Are you sure you want to delete the selected bookmarks/folders?");
  }
  return true;
}
}
if (func==1) {
alert("Please check at least one bookmark to move.");
} else {
alert("Please check at least one bookmark to delete.");
}

return false;
}
function CheckAll(checked) {
var i;
for (i=0; document.bookmarks_form.elements[i]; i++) {
if (document.bookmarks_form.elements[i].type == "checkbox" &&
(document.bookmarks_form.elements[i].name == "bid" || document.bookmarks_form.elements[i].name == "fid")) {
document.bookmarks_form.elements[i].checked = checked;
}
}
}

}
}

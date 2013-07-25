var PHIGITA = {
init: function() {
var link = document.createElement("link");
link.rel = "stylesheet";
link.type = "text/css";
link.href = "http://www.phigita.net/desktop.css";
if (document.all) {
document.documentElement.appendChild(link);
} else {
document.documentElement.childNodes[0].appendChild(link);
}
div.id = '__phigita_1_part';
div.className = 'part';
div.style.top = '30px';
div.style.left = '5px';
div.style.zIndex = 1;
div.style.width = '128px';
div.style.height = '17px';
a = document.createElement('a');
a.href = 'javascript:PHIGITA.href(\"http://www.alexa.com/data/details/traffic_details?q=&url=\"+location.hostname)';
a.title = 'javascript:PHIGITA.href(\"http://www.alexa.com/data/details/traffic_details?q=&url=\"+location.hostname)';
a.onmousedown = PHIGITA.storeSelection;
a.onclick = PHIGITA.close;
a.innerHTML = '';
if (document.all) {
a.innerHTML += '<img src="http://www.blummy.com/icon.php?id=2" alt="Alexa SiteInfo" style="margin-right: 3px; width: 16px; height: 16px" />';
} else {
a.innerHTML += '<img src="data:image/x-icon;base64,PCFET0NUWVBFIEhUTUwgUFVCTElDICItLy9XM0MvL0RURCBIVE1MIDQuMDEvL0VOIgogICAgICJodHRwOi8vd3d3LnczLm9yZy9UUi9odG1sNC9zdHJpY3QuZHRkIj4KPGh0bWw+CiAgPGhlYWQ+CiAgICA8dGl0bGU+QWxleGEgV2ViIFNlYXJjaCAtLSBTZXJ2aWNlIE5vdCBBdmFpbGFibGU8L3RpdGxlPgogICAgPG1ldGEgaHR0cC1lcXVpdj0iQ29udGVudC1UeXBlIiBjb250ZW50PSJ0ZXh0L2h0bWw7IGNoYXJzZXQ9aXNvLTg4NTktMSI+Cgk8bGluayBocmVmPSJodHRwOi8vY2xpZW50LmFsZXhhLmNvbS9jb21tb24vY3NzL3N0eWxlcy5jc3MiIHNyYz0iaHR0cDovL2NsaWVudC5hbGV4YS5jb20vY29tbW9uL2Nzcy9zdHlsZXMuY3NzIiByZWw9InN0eWxlc2hlZXQiIHR5cGU9InRleHQvY3NzIi8+CjxzY3JpcHQgdHlwZT0idGV4dC9qYXZhc2NyaXB0IiBsYW5ndWFnZT0iSmF2YVNjcmlwdCI+Cgl2YXIgZGlzYWJsZV9kZWJ1Z19oYW5kbGVyPWZhbHNlOwo8L3NjcmlwdD4KPHNjcmlwdCBzcmM9Imh0dHA6Ly9jbGllbnQuYWxleGEuY29tL2NvbW1vbi9qcy9iZWhhdmlvci5qcyIgdHlwZT0idGV4dC9qYXZhc2NyaXB0IiBsYW5ndWFnZT0iSmF2YVNjcmlwdCI+PC9zY3JpcHQ+CjxzY3JpcHQgc3JjPSJodHRwOi8vY2xpZW50LmFsZXhhLmNvbS9jb21tb24vanMvYmVoYXZpb3VyLmpzIiB0eXBlPSJ0ZXh0L2phdmFzY3JpcHQiIGxhbmd1YWdlPSJKYXZhU2NyaXB0Ij48L3NjcmlwdD4KPHNjcmlwdCBzcmM9Imh0dHA6Ly9jbGllbnQuYWxleGEuY29tL2NvbW1vbi9qcy9wcm90b3R5cGUuanMiIHR5cGU9InRleHQvamF2YXNjcmlwdCIgbGFuZ3VhZ2U9IkphdmFTY3JpcHQiPjwvc2NyaXB0Pgo8c2NyaXB0IHNyYz0iaHR0cDovL2NsaWVudC5hbGV4YS5jb20vY29tbW9uL2pzL3NlYXJjaF9mdW5jdGlvbnMuanMiIHR5cGU9InRleHQvamF2YXNjcmlwdCIgbGFuZ3VhZ2U9ImphdmFzY3JpcHQiPjwvc2NyaXB0Pgo8c2NyaXB0IHNyYz0iaHR0cDovL2NsaWVudC5hbGV4YS5jb20vY29tbW9uL2pzL2VudW0uanMiIHR5cGU9InRleHQvamF2YXNjcmlwdCIgbGFuZ3VhZ2U9ImphdmFzY3JpcHQiPjwvc2NyaXB0Pgo8c2NyaXB0IHNyYz0iaHR0cDovL2NsaWVudC5hbGV4YS5jb20vY29tbW9uL2pzL3N3YXAuanMiIHR5cGU9InRleHQvamF2YXNjcmlwdCIgbGFuZ3VhZ2U9ImphdmFzY3JpcHQiPjwvc2NyaXB0Pgo8c2NyaXB0IHNyYz0iaHR0cDovL2NsaWVudC5hbGV4YS5jb20vY29tbW9uL2pzL2xvYWQuanMiIHR5cGU9InRleHQvamF2YXNjcmlwdCIgbGFuZ3VhZ2U9ImphdmFzY3JpcHQiPjwvc2NyaXB0Pgo8c2NyaXB0IHNyYz0iaHR0cDovL2NsaWVudC5hbGV4YS5jb20vY29tbW9uL2pzL3htbC5qcyIgdHlwZT0idGV4dC9qYXZhc2NyaXB0IiBsYW5ndWFnZT0iSmF2YVNjcmlwdCI+PC9zY3JpcHQ+CjxzY3JpcHQgc3JjPSJodHRwOi8vY2xpZW50LmFsZXhhLmNvbS9jb21tb24vanMvZXh0ZXJuYWxfbGlua3MuanMiIHR5cGU9InRleHQvamF2YXNjcmlwdCIgbGFuZ3VhZ2U9IkphdmFTY3JpcHQiPjwvc2NyaXB0Pgo8c2NyaXB0IHNyYz0iaHR0cDovL2NsaWVudC5hbGV4YS5jb20vY29tbW9uL2pzL3NpZGViYXJzLmpzIiB0eXBlPSJ0ZXh0L2phdmFzY3JpcHQiIGxhbmd1YWdlPSJKYXZhU2NyaXB0Ij48L3NjcmlwdD4KPHNjcmlwdCBzcmM9Imh0dHA6Ly9jbGllbnQuYWxleGEuY29tL2NvbW1vbi9qcy9oaXRzbGlua190cmFja2luZy5qcyIgdHlwZT0idGV4dC9qYXZhc2NyaXB0IiBsYW5ndWFnZT0iamF2YXNjcmlwdCI+PC9zY3JpcHQ+CgoKPHNjcmlwdCBsYW5ndWFnZT0iamF2YXNjcmlwdCIgdHlwZT0idGV4dC9qYXZhc2NyaXB0IiBzcmM9Imh0dHA6Ly9jbGllbnQuYWxleGEuY29tL2NvbW1vbi9qcy9oaXRzbGlua190cmFja2luZy5qcyI+PC9zY3JpcHQ+CgoKCgoKCiAgICA8c2NyaXB0IGxhbmd1YWdlPSJqYXZhc2NyaXB0IiB0eXBlPSJ0ZXh0L2phdmFzY3JpcHQiIHNyYz0iaHR0cDovL2NsaWVudC5hbGV4YS5jb20vY29tbW9uL2pzL2hpdHNsaW5rX3RyYWNraW5nLmpzIj48L3NjcmlwdD4KICAgIDxsaW5rIGhyZWY9Imh0dHA6Ly9jbGllbnQuYWxleGEuY29tL2NvbW1vbi9jc3MvY29tcGFueV9oZWxwLmNzcyIgdHlwZT0idGV4dC9jc3MiIHJlbD0ic3R5bGVzaGVldCIgc3JjPSJodHRwOi8vY2xpZW50LmFsZXhhLmNvbS9jb21tb24vY3NzL2NvbXBhbnlfaGVscC5jc3MiLz4KICA8L2hlYWQ+CgogIDxib2R5IGlkPSJIZWxwIj4KCgk8ZGl2IGlkPSJjb250YWluZXIiPgoKICAgICAgPGRpdiBpZD0iaGVhZGVyQ29udGFpbmVyIj4KPGRpdiBpZD0iaGVhZGVyIiBjbGFzcz0ic2l0ZSI+CjxkaXYgaWQ9ImhlYWRlcl9sb2dvIj4KPGEgaHJlZj0iaHR0cDovL3d3dy5hbGV4YS5jb20iPjxpbWcgYWxpZ249ImxlZnQiIGFsdD0iQWxleGEuY29tIiBzcmM9Imh0dHA6Ly9jbGllbnQuYWxleGEuY29tL2NvbW1vbi9pbWFnZXMvY29tcGFjdF9oZWFkZXJfbG9nby5naWYiPjwvYT4KPC9kaXY+CjxkaXYgaWQ9InNlYXJjaF9ib3giPgo8ZGwgaWQ9InNlYXJjaF9hcmVhIj4KPGR0IGlkPSJ0YWJfc2VhcmNoIiBjbGFzcz0iIj4KPGEgaHJlZj0iI3NlYXJjaCIgY2xhc3M9InRhYiI+V2ViIFNlYXJjaDwvYT4KPC9kdD4KPGRkIGNsYXNzPSIiPgo8Zm9ybSBlbmN0eXBlPSJhcHBsaWNhdGlvbi94LXd3dy1mb3JtLXVybGVuY29kZWQiIG1ldGhvZD0iZ2V0IiBhY3Rpb249Imh0dHA6Ly93d3cuYWxleGEuY29tL3NlYXJjaCIgbmFtZT0id2Vic2VhcmNoX2Zvcm0iPgoKPGlucHV0IHZhbHVlPSIiIG5hbWU9InEiIHNpemU9IjQwIiBjbGFzcz0ic2VhcmNoX3ZhbHVlIiBpZD0ic2VhcmNoX2lucHV0Ij48aW5wdXQgdmFsdWU9IldlYiBTZWFyY2giIHR5cGU9InN1Ym1pdCI+CjwvZm9ybT4KPC9kZD4KPGR0IGlkPSJ0YWJfdHJhZmZpYyIgY2xhc3M9IiI+CjxhIGhyZWY9IiN0cmFmZmljIiBjbGFzcz0idGFiIj5UcmFmZmljIFJhbmtpbmdzPC9hPgo8L2R0Pgo8ZGQgY2xhc3M9IiI+Cjxmb3JtIGVuY3R5cGU9ImFwcGxpY2F0aW9uL3gtd3d3LWZvcm0tdXJsZW5jb2RlZCIgbWV0aG9kPSJnZXQiIGFjdGlvbj0iaHR0cDovL3d3dy5hbGV4YS5jb20vZGF0YS9kZXRhaWxzL21haW4iIG5hbWU9InRyYWZmaWNfZm9ybSI+CjxpbnB1dCB2YWx1ZT0iIiBuYW1lPSJxIiBjbGFzcz0ic2VhcmNoX3ZhbHVlIiB0eXBlPSJoaWRkZW4iPjxpbnB1dCB0aXRsZT0iUGxlYXNlIGVudGVyIGEgd2ViIGFkZHJlc3MiIG9uY2hhbmdlPSJjb3B5RmllbGQoJ3RyYWZmaWNfZm9ybScsdGhpcy5uYW1lLCdxJyk7IiB2YWx1ZT0iIiBzaXplPSIyNyIgbmFtZT0idXJsIiBjbGFzcz0ic2VhcmNoX3ZhbHVlIiB0eXBlPSJ0ZXh0Ij48aW5wdXQgdmFsdWU9IkdldCBUcmFmZmljIERldGFpbHMiIHR5cGU9InN1Ym1pdCI+PGEgY2xhc3M9InNtYWxsIiBocmVmPSJodHRwOi8vd3d3LmFsZXhhLmNvbS9zaXRlL2RzL3RvcF81MDAiPlRvcCA1MDA8L2E+IC0gPGEgY2xhc3M9InNtYWxsIiBocmVmPSJodHRwOi8vd3d3LmFsZXhhLmNvbS9zaXRlL2RzL21vdmVyc19zaGFrZXJzP2xhbmc9ZW4iPk1vdmVycyAmYW1wOyBTaGFrZXJzPC9hPgo8L2Zvcm0+Cgo8L2RkPgo8ZHQgaWQ9InRhYl9kaXJlY3RvcnkiIGNsYXNzPSIiPgo8YSBocmVmPSIjZGlyZWN0b3J5IiBjbGFzcz0idGFiIj5XZWIgRGlyZWN0b3J5PC9hPgo8L2R0Pgo8ZGQgY2xhc3M9IiI+Cjxmb3JtIGVuY3R5cGU9ImFwcGxpY2F0aW9uL3gtd3d3LWZvcm0tdXJsZW5jb2RlZCIgbWV0aG9kPSJnZXQiIGFjdGlvbj0iaHR0cDovL3d3dy5hbGV4YS5jb20vYnJvd3NlL3NlYXJjaCIgbmFtZT0iYnJvd3NlX2Ryb3BfZm9ybSI+CjxpbnB1dCBuYW1lPSJJZExpbmsiIHR5cGU9ImhpZGRlbiIgdmFsdWU9IjEiPjxzcGFuIGNsYXNzPSJzbWFsbCI+U2VhcmNoIGZvcjombmJzcDs8L3NwYW4+PGlucHV0IHZhbHVlPSIiIHNpemU9IjIwIiBjbGFzcz0ic2VhcmNoX3ZhbHVlIiBuYW1lPSJRdWVyeSIgdHlwZT0idGV4dCI+PHNwYW4gY2xhc3M9InNtYWxsIj4mbmJzcDtpbiZuYnNwOzwvc3Bhbj48c2VsZWN0IHN0eWxlPSJ3aWR0aD0xMzBweCIgbmFtZT0iQ2F0ZWdvcnlJRCI+PG9wdGlvbiB2YWx1ZT0iIj5BbGwgU3ViamVjdHM8L29wdGlvbj48b3B0aW9uIHZhbHVlPSJUb3AvQXJ0cyI+QXJ0czwvb3B0aW9uPjxvcHRpb24gdmFsdWU9IlRvcC9CdXNpbmVzcyI+QnVzaW5lc3M8L29wdGlvbj48b3B0aW9uIHZhbHVlPSJUb3AvQ29tcHV0ZXJzIj5Db21wdXRlcnM8L29wdGlvbj48b3B0aW9uIHZhbHVlPSJUb3AvR2FtZXMiPkdhbWVzPC9vcHRpb24+PG9wdGlvbiB2YWx1ZT0iVG9wL0hlYWx0aCI+SGVhbHRoPC9vcHRpb24+PG9wdGlvbiB2YWx1ZT0iVG9wL0hvbWUiPkhvbWU8L29wdGlvbj48b3B0aW9uIHZhbHVlPSJUb3AvS2lkc19hbmRfVGVlbnMiPktpZHNfYW5kX1RlZW5zPC9vcHRpb24+PG9wdGlvbiB2YWx1ZT0iVG9wL05ld3MiPk5ld3M8L29wdGlvbj48b3B0aW9uIHZhbHVlPSJUb3AvUmVjcmVhdGlvbiI+UmVjcmVhdGlvbjwvb3B0aW9uPjxvcHRpb24gdmFsdWU9IlRvcC9SZWZlcmVuY2UiPlJlZmVyZW5jZTwvb3B0aW9uPjxvcHRpb24gdmFsdWU9IlRvcC9SZWdpb25hbCI+UmVnaW9uYWw8L29wdGlvbj48b3B0aW9uIHZhbHVlPSJUb3AvU2NpZW5jZSI+U2NpZW5jZTwvb3B0aW9uPjxvcHRpb24gdmFsdWU9IlRvcC9TaG9wcGluZyI+U2hvcHBpbmc8L29wdGlvbj48b3B0aW9uIHZhbHVlPSJUb3AvU29jaWV0eSI+U29jaWV0eTwvb3B0aW9uPjxvcHRpb24gdmFsdWU9IlRvcC9TcG9ydHMiPlNwb3J0czwvb3B0aW9uPjxvcHRpb24gdmFsdWU9IlRvcC9Xb3JsZCI+V29ybGQ8L29wdGlvbj48L3NlbGVjdD48aW5wdXQgdmFsdWU9IkRpcmVjdG9yeSBTZWFyY2giIHR5cGU9InN1Ym1pdCI+Cgo8L2Zvcm0+CjwvZGQ+CjxkdCBpZD0idGFiX3NpdGUiPgo8YSBocmVmPSIjc2l0ZSIgY2xhc3M9InRhYiI+PC9hPgo8L2R0Pgo8ZGQgY2xhc3M9InNlbGVjdGVkIj4KPGZvcm0gc3R5bGU9ImZsb2F0OiByaWdodDsiIGVuY3R5cGU9ImFwcGxpY2F0aW9uL3gtd3d3LWZvcm0tdXJsZW5jb2RlZCIgbWV0aG9kPSJwb3N0IiBhY3Rpb249Imh0dHA6Ly94c2x0LmFsZXhhLmNvbS9jZ2ktYmluL3NlYXJjaF9mb3JtIiBuYW1lPSJzaXRlX3NlYXJjaF9mb3JtIj4KPGlucHV0IHZhbHVlPSJwYWdlcy5hbGV4YS5jb20iIG5hbWU9InNpdGUiIHR5cGU9ImhpZGRlbiI+PGlucHV0IHZhbHVlPSIiIG5hbWU9InNlYXJjaCIgc2l6ZT0iMzAiIGNsYXNzPSJzZWFyY2hfdmFsdWUiIGlkPSJzZWFyY2hfaW5wdXQiPjxpbnB1dCB2YWx1ZT0iU2VhcmNoIG91ciBTaXRlIiB0eXBlPSJzdWJtaXQiPgo8L2Zvcm0+CjwvZGQ+CjwvZGw+CjwvZGl2Pgo8L2Rpdj4KPC9kaXY+CjxzY3JpcHQgdHlwZT0idGV4dC9qYXZhc2NyaXB0IiBsYW5ndWFnZT0iamF2YXNjcmlwdCI+CjwhLS0KCQlmdW5jdGlvbiBsb2FkX3N3YXAoKSB7CgkJCXRyeSB7IGlmICghanNBbGwpIHsganNBbGwgPSBuZXcgSlNBbGwoKTsgfSB9IGNhdGNoIChleCkgeyBqc0FsbCA9IG5ldyBKU0FsbCgpOyB9CgkJfQoKCQlsb2FkX3N3YXAoKTsKCQkvL2FkdnMoKTsgLy9mb3IgYWR2YW5jZWQgc2VhcmNoCgkvLyAtLT48L3NjcmlwdD4KCgk8YnIgY2xlYXI9ImFsbCIvPgogICAgIDxkaXYgaWQ9ImNvbnRlbnQiPgoJCTxoMT5IZWxwPC9oMT4KCgkJPGRpdiBpZD0ic2l0ZVNpZGVOYXZDb250YWluZXIiPgo8ZGl2IGlkPSJzaXRlU2lkZU5hdiI+CjxkaXYgY2xhc3M9InRvcF9kaXZpZGVyIj48L2Rpdj4KPGgyPgo8YSBocmVmPSJodHRwOi8vd3d3LmFsZXhhLmNvbS9zaXRlL2RldmNvcm5lciI+RGV2ZWxvcGVyJ3MgQ29ybmVyPC9hPgo8L2gyPgo8ZGl2IGlkPSJEZXZDb3JuZXJfbmF2IiBjbGFzcz0ibmF2YmFyIj4KPHVsPgo8bGk+CjxhIGhyZWY9Imh0dHA6Ly93d3cuYWxleGEuY29tL3NpdGUvZGV2Y29ybmVyIj5PdmVydmlldzwvYT4KPC9saT4KPGxpPgoKPGEgaHJlZj0iaHR0cDovL3dlYnNlYXJjaC5hbGV4YS5jb20iPldlYiBTZWFyY2ggUGxhdGZvcm08L2E+CjwvbGk+CjxsaT4KPGEgaHJlZj0iaHR0cDovL3d3dy5hbGV4YS5jb20vc2l0ZS9kZXZjb3JuZXIvc2FtcGxlcyI+U2FtcGxlIEFwcHMgJmFtcDsgVHV0b3JpYWxzPC9hPgo8L2xpPgo8bGk+CjxhIGhyZWY9Imh0dHA6Ly93d3cuYWxleGEuY29tL3NpdGUvZGV2Y29ybmVyL3dlYl9pbmZvX3NlcnZpY2VzIj5EYXRhIFNlcnZpY2VzPC9hPgo8L2xpPgo8bGk+CjxhIGhyZWY9Imh0dHA6Ly93d3cuYWxleGEuY29tL3NpdGUvZGV2Y29ybmVyL3dlYm1hc3RlcnMiPldlYm1hc3RlciBTZXJ2aWNlczwvYT4KPC9saT4KCjxsaT4KPGEgaHJlZj0iaHR0cDovL3d3dy5hbGV4YS5jb20vc2l0ZS9kZXZjb3JuZXIvcnNzX2ZlZWRzIj5SU1MgRmVlZHM8L2E+CjwvbGk+CjxsaT4KPGEgaHJlZj0iaHR0cDovL2RldmVsb3Blci5hbWF6b253ZWJzZXJ2aWNlcy5jb20vY29ubmVjdC9mb3J1bS5qc3BhP2ZvcnVtSUQ9MTUiPkZvcnVtczwvYT4KPC9saT4KPC91bD4KPGRpdiBjbGFzcz0iaG9yaXpfZGl2aWRlciI+PC9kaXY+CjwvZGl2Pgo8aDI+CjxhIGhyZWY9Imh0dHA6Ly93d3cuYWxleGEuY29tL3NpdGUvY29tcGFueSI+Q29tcGFueSBJbmZvPC9hPgo8L2gyPgo8ZGl2IGlkPSJDb21wYW55X25hdiIgY2xhc3M9Im5hdmJhciI+Cjx1bD4KCjxsaT4KPGEgaHJlZj0iaHR0cDovL3d3dy5hbGV4YS5jb20vc2l0ZS9jb21wYW55Ij5PdmVydmlldzwvYT4KPC9saT4KPGxpPgo8YSBocmVmPSJodHRwOi8vd3d3LmFsZXhhLmNvbS9zaXRlL2NvbXBhbnkvaGlzdG9yeSI+SGlzdG9yeTwvYT4KPC9saT4KPGxpPgo8YSBocmVmPSJodHRwOi8vd3d3LmFsZXhhLmNvbS9zaXRlL2NvbXBhbnkvdGVjaG5vbG9neSI+VGVjaG5vbG9neTwvYT4KPC9saT4KPGxpPgo8YSBocmVmPSJodHRwOi8vd3d3LmFsZXhhLmNvbS9zaXRlL2NvbXBhbnkvbWFuYWdlcnMiPk1hbmFnZXJzPC9hPgo8L2xpPgo8bGk+Cgo8YSBocmVmPSJodHRwOi8vd3d3LmFsZXhhLmNvbS9zaXRlL2NvbXBhbnkvam9iX29wZW5pbmdzIj5Kb2JzPC9hPgo8L2xpPgo8bGk+CjxhIGhyZWY9Imh0dHA6Ly93d3cuYWxleGEuY29tL3NpdGUvY29tcGFueS9uZXdzIj5OZXdzICZhbXA7IFByZXNzIFJlbGVhc2VzPC9hPgo8L2xpPgo8bGk+CjxhIGhyZWY9Imh0dHA6Ly93d3cuYWxleGEuY29tL3NpdGUvY29tcGFueS9jb250YWN0Ij5Db250YWN0IFVzPC9hPgo8L2xpPgo8bGk+CjxhIGhyZWY9Imh0dHA6Ly93d3cuYWxleGEuY29tL3NpdGUvY29tcGFueS9kaXJlY3Rpb25zIj5Ecml2aW5nIERpcmVjdGlvbnM8L2E+CjwvbGk+Cgo8L3VsPgo8ZGl2IGNsYXNzPSJob3Jpel9kaXZpZGVyIj48L2Rpdj4KPC9kaXY+CjxoMj4KPGEgaHJlZj0iaHR0cDovL3d3dy5hbGV4YS5jb20vc2l0ZS9oZWxwIj5IZWxwPC9hPgo8L2gyPgo8ZGl2IGlkPSJIZWxwX25hdiIgY2xhc3M9Im5hdmJhciI+Cjx1bD4KPGxpPgo8YSBocmVmPSJodHRwOi8vd3d3LmFsZXhhLmNvbS9zaXRlL2hlbHAiPk92ZXJ2aWV3PC9hPgo8L2xpPgo8bGk+CjxhIGhyZWY9Imh0dHA6Ly93d3cuYWxleGEuY29tL3NpdGUvaGVscC93ZWJtYXN0ZXJzIj5XZWJtYXN0ZXJzPC9hPgo8L2xpPgoKPGxpPgo8YSBocmVmPSJodHRwOi8vd3d3LmFsZXhhLmNvbS9zaXRlL2hlbHAvcHJpdmFjeSI+UHJpdmFjeSBQb2xpY3k8L2E+CjwvbGk+CjxsaT4KPGEgaHJlZj0iaHR0cDovL3d3dy5hbGV4YS5jb20vc2l0ZS9oZWxwL3Rlcm1zIj5UZXJtcyBvZiBVc2U8L2E+CjwvbGk+CjwvdWw+CjwvZGl2Pgo8ZGl2IGNsYXNzPSJob3Jpel9kaXZpZGVyIj48L2Rpdj4KPC9kaXY+CgkJCTxici8+CgkJCTxhIGhyZWY9Imh0dHA6Ly93ZWJzZWFyY2guYWxleGEuY29tLyIgdGl0bGU9IkFsZXhhIFdlYiBTZWFyY2ggUGxhdGZvcm0iPjxpbWcgc3JjPSJodHRwOi8vY2xpZW50LmFsZXhhLmNvbS9jb21tb24vaW1hZ2VzL25vdy1vcGVuLXNtYWxsLmpwZyIvPjwvYT48YnIvPjxici8+CgkJCTxhIGhyZWY9Imh0dHA6Ly9kb3dubG9hZC5hbGV4YS5jb20vIiB0aXRsZT0iQWxleGEgVG9vbGJhciBEb3dubG9hZCI+PGltZyBzcmM9Imh0dHA6Ly9jbGllbnQuYWxleGEuY29tL2NvbW1vbi9pbWFnZXMvdG9vbGJhci1hZC5qcGciLz48L2E+Cgo8L2Rpdj4KCgoJCQk8ZGl2IGlkPSJyaWdodENvbCI+CiAgICAgICAgICAgICAgICAgICAgICA8aDI+U2VydmljZSBOb3QgQXZhaWxhYmxlPC9oMj4KICAgICAgICAgICAgICAgICAgICAgIDxwPldlJ3JlIHNvcnJ5LiBXZSBjb3VsZCBub3QgcHJvY2VzcyB5b3VyIHJlcXVlc3QuIFBsZWFzZSB0cnkgYWdhaW4gaW4gYSBmZXcgbWludXRlcy48L3A+CiAgICAgICAgICAgICAgICAgICAgICA8cD5IZXJlIGFyZSBzb21lIGxpbmtzIHRvIGdldCB5b3UgZ29pbmcgYWdhaW46PC9wPgogICAgICAgICAgICAgICAgICAgICAgPHVsPgogICAgICAgICAgICAgICAgICAgICAgICA8bGk+PGEgaHJlZj0iaHR0cDovL3d3dy5hbGV4YS5jb20vIj5BbGV4YSBIb21lIFBhZ2U8L2E+PC9saT4KICAgICAgICAgICAgICAgICAgICAgICAgPGxpPjxhIGhyZWY9Imh0dHA6Ly93d3cuYWxleGEuY29tL3NpdGUvaGVscCI+QWxleGEgSGVscCBhbmQgRnJlcXVlbnRseSBBc2tlZCBRdWVzdGlvbnM8L2E+PC9saT4KICAgICAgICAgICAgICAgICAgICAgICAgPGxpPjxhIGhyZWY9Imh0dHA6Ly93d3cuYWxleGEuY29tL3NpdGUvY29tcGFueSI+QWJvdXQgQWxleGE8L2E+PC9saT4KICAgICAgICAgICAgICAgICAgICAgICAgPGxpPjxhIGhyZWY9Imh0dHA6Ly93d3cuYWxleGEuY29tL3NpdGUvZGV2Y29ybmVyIj5BbGV4YSBQcm9kdWN0cyBhbmQgU2VydmljZXM8L2E+PC9saT4KICAgICAgICAgICAgICAgICAgICAgICAgPGxpPjxhIGhyZWY9Imh0dHA6Ly93d3cuYWxleGEuY29tL3NpdGUvaGVscC9wcml2YWN5Ij5Qcml2YWN5IFBvbGljeTwvYT48L2xpPgogICAgICAgICAgICAgICAgICAgICAgPC91bD4KCiAgICAgICAgICAgIDwvZGl2PgoJCTwvZGl2PjwhLS0gZW5kIGNvbnRlbnQgZGl2IC0tPgogICAgICA8IS0tIEZPT1RFUiAtLT4KICA8ZGl2IGlkPSJmb290ZXIiIGNsYXNzPSJsaW5lIj4KICAgICAgPCEtLSBURVhUIExJTktTIC0tPgogICAgICA8cCBjbGFzcz0iYm9keSIgYWxpZ249ImNlbnRlciI+CiAgICAgICAgPGEgaHJlZj0iaHR0cDovL3BhZ2VzLmFsZXhhLmNvbS9jb21wYW55L2luZGV4Lmh0bWwiPkFib3V0IEFsZXhhPC9hPiYjMTYwO3wKICAgICAgICA8YSBocmVmPSJodHRwOi8vcGFnZXMuYWxleGEuY29tL2NvbXBhbnkvbmV3cy5odG1sIj5BbGV4YSBpbiB0aGUgTmV3cyE8L2E+JiMxNjA7fAogICAgICAgIDxhIGhyZWY9Imh0dHA6Ly9kb3dubG9hZC5hbGV4YS5jb20vP3A9Q29ycF9XX3RfNDBfQjEiPkRvd25sb2FkIHRoZSBBbGV4YSBUb29sYmFyPC9hPiYjMTYwO3wKICAgICAgICA8YSBocmVmPSJodHRwOi8vd2Vic2VhcmNoLmFsZXhhLmNvbSI+QWxleGEgV2ViIFNlYXJjaCBQbGF0Zm9ybTwvYT4mIzE2MDt8CiAgICAgICAgPGEgaHJlZj0iaHR0cDovL3BhZ2VzLmFsZXhhLmNvbS9leGVjL2ZhcXNpZG9zL2hlbHAvaW5kZXguaHRtbCI+SGVscDwvYT4KICAgICAgPC9wPgogICAgICA8cCBjbGFzcz0iZm9vdFRleHQiIGFsaWduPSJjZW50ZXIiPgogICAgICAgIDxhIGhyZWY9Imh0dHA6Ly9wYWdlcy5hbGV4YS5jb20vaGVscC9wcml2YWN5Lmh0bWwiPlByaXZhY3kgUG9saWN5PC9hPiYjMTYwO3wKICAgICAgICA8YSBocmVmPSJodHRwOi8vcGFnZXMuYWxleGEuY29tL2hlbHAvdGVybXMuaHRtbCI+VGVybXMgb2YgVXNlPC9hPgogICAgICA8L3A+CiAgICAgIDwhLS0gQ09QWVJJR0hUIEFORCBBTUFaT04gTElOSyAtLT4KICAgICAgPHAgY2xhc3M9ImZvb3RUZXh0IiBhbGlnbj0iY2VudGVyIj4mIzE2OTsKICAgICAgCQkJPHNjcmlwdCBsYW5ndWFnZT0iSmF2YXNjcmlwdCIgdHlwZT0idGV4dC9qYXZhc2NyaXB0Ij4KCQkJCQl2YXIgdG9kYXkgPSBuZXcgRGF0ZSgpOwoJCQkJCXZhciB5ZWFyID0gdG9kYXkuZ2V0RnVsbFllYXIoKTsKCQkJCQlkb2N1bWVudC53cml0ZSgnMTk5Ni0nICsgeWVhciArICcsJyk7CgkJCQk8L3NjcmlwdD4gQWxleGEgSW50ZXJuZXQsIEluYy48L3A+CiAgICAgIDxwIGFsaWduPSJjZW50ZXIiPjxhIGhyZWY9Imh0dHA6Ly9yZWRpcmVjdC5hbGV4YS5jb20vYW1hem9uL2hvbWUiPjxpbWcgc3JjPSJodHRwOi8vY2xpZW50LmFsZXhhLmNvbS9jb21tb24vaW1hZ2VzL2FuX2FtYXpvbl9jb21wYW55LmdpZiIgd2lkdGg9IjE2MCIgaGVpZ2h0PSIyMSIgYm9yZGVyPSIwIiBhbHQ9IkFuIEFtYXpvbi5jb20gQ29tcGFueSIvPjwvYT48L3A+CiAgPC9kaXY+CjwhLS0gL0ZPT1RFUiAtLT4KCgoJPC9kaXY+CiAgPC9ib2R5Pgo8L2h0bWw+Cg==" alt="Alexa SiteInfo" style="margin-right: 3px; width: 16px; height: 16px" />';
}a.innerHTML += 'Alexa SiteInfo';
div.appendChild(a);
this.div.appendChild(div);div = document.createElement('div');
div.id = '__phigita_2_part';
div.style.top = '50px';
div.style.left = '5px';
div.style.width = '110px';
div.style.height = '40px';
div.style.zIndex = 1;
a = document.createElement('a');
a.target ='_blank';
a.href = 'http://www.pagerank.net/';
a.title = 'http://www.pagerank.net/';
img = document.createElement('img');
img.src = 'http://www.pagerank.net/pagerank.gif';
a.appendChild(img);
div.appendChild(a);
this.div.appendChild(div);div = document.createElement('div');
div = document.createElement('div');
div.className = 'copyright';
div.innerHTML = 'this is <a class="blummyhome" href="http://www.blummy.com/">blummy</a> (<a class="blummygrey" href="http://www.blummy.com/config.php?user=anon">config</a>) | &copy; <a class="blummygrey" style="text-decoration: none" href="http://alexander.kirk.at/">a.kirk</a> 2006 | user <b>anon</b>';
var a = document.createElement('a');
a.className = 'blummygrey';
a.href = 'javascript:void(PHIGITA.close())';
a.innerHTML = 'close';
this.div.appendChild(div);
div = document.createElement('div');
div.className = 'close';
div.style.right = "2px";
div.style.top = "0px";
div.appendChild(a);
this.div.appendChild(div);
this.div.style.height = '130px';
this.div.style.width = '362px';
this.div.id = 'phigita';
var w = (document.all) ? document.body.offsetWidth : window.innerWidth;
this.div.style.left = Math.floor((w - 362) * 10 / 100) + 'px';if (document.all) {
document.documentElement.childNodes[1].appendChild(this.div);
} else {
document.documentElement.appendChild(this.div);
}
var l = document.getElementById('loadingblummy');
if (!l) l = document.getElementById('l_blm');
if (l) {
l.style.display = 'none';
}
this.show();		this.show_message();
},	
scrollPos: function() {
if (document.all) {
return document.body.scrollTop;
} else {
return window.pageYOffset;
}
},
show_message: function() {
var i = Math.floor(Math.random() * this.messages.length + 0.5);
if (i == 0 || 'anon' == 'anon') {
return;
}
div = document.createElement('div');
div.id = '__phigita_msg';
div.style.top = '115px';
div.style.width = '352px';
div.style.left = '5px';
div.style.zIndex = 1;
div.className = "blummymsg";
div.style.backgroundColor = "#fff";
var m = this.messages[i-1];
m += ' <a href="javascript:void(document.getElementById(\'__phigita_msg\').style.display=\'none\')" class="blummygrey">hide msg</a>';
div.innerHTML = m;
this.div.appendChild(div);
},
show: function() {
var el = document.getElementById(this.div.id);
el.style.display = "block";
if ((document.all && !window.opera)
|| (document.all && window.opera && window.opera.version() < 9)) {
p = this.scrollPos();
if (this.pos != p) {
el.style.top = p + "px";
this.posWiki();
this.pos = p;
}
if (!this.scrollInterval) this.scrollInterval = window.setInterval("PHIGITA.show()", 1000);
} else {
//el.style.top = 0;
el.style.position = "fixed";
}
},
wikiPos: 0,
showWiki: function(pos) {
var d = document.getElementById("blummy_wiki");
if (d) {
if (pos && this.wikiPos != pos) {
this.wikiPos = pos;
this.posWiki();
} else {
d.style.display = (d.style.display != "block") ? "block" : "none";
}
} else {
d = document.createElement("div");
d.id = "blummy_wiki";
d.innerHTML = '<iframe src="http://www.phigita.net/wiki.php"></iframe>';
d.className = "blummy";
d.style.backgroundColor = this.div.style.backgroundColor;
d.style.opacity = this.div.style.opacity;
d.style.filter = this.div.style.filter;
d.style.height = this.div.style.height;
if (document.all) {
document.documentElement.childNodes[1].appendChild(d);
} else {
document.documentElement.appendChild(d);
}
d.style.display = "block";
if (pos) {
this.wikiPos = pos;
}
this.posWiki();
}
},
posWiki: function() {
var d = document.getElementById("blummy_wiki");
if (!d) { return false; }
if (document.all
|| (document.all && window.opera && window.opera.version() < 9)) {
d.style.position = "absolute";
} else {
d.style.position = "fixed";
}
d.style.borderLeft = "1px solid #28d524";
d.style.borderRight = "1px solid #28d524";
switch(this.wikiPos) {
case 1: // left
d.style.width = "200px";
d.style.height = this.div.style.height;
d.style.top = 0;
d.style.left = (parseInt(this.div.style.left) - parseInt(d.style.width) - 1) + "px";
d.style.borderRight = 0;
break;
case 2: // bottom
d.style.width = this.div.style.width;
d.style.height = "80px";
d.style.top = (parseInt(this.div.style.height) + 1) + "px";
d.style.left = this.div.style.left;
break;
case 3: // right
d.style.width = "200px";
d.style.height = this.div.style.height;
d.style.top = 0;
d.style.left = (parseInt(this.div.style.left) + parseInt(this.div.style.width) + 2) + "px";
d.style.borderLeft = 0;
break;
default:
d.style.display = "none";
}
d.firstChild.style.width = d.style.width;
d.firstChild.style.height = d.style.height;
},
close: function() {
if (this != PHIGITA) {
return PHIGITA.close();
}
var d = document.getElementById(this.div.id);
var w = document.getElementById("blummy_wiki");
if (d.style.display != "none") {
window.clearInterval(this.scrollInterval);
if (w) w.style.display = 'none';
d.style.display = "none";
this.pos = -1;
this.scrollInterval = null;
} else {
this.show();
if (w) w.style.display = 'block';
}
},
storeSelection: function() {
if (window.getSelection) {
s = window.getSelection();
} else if (document.getSelection) {
s = document.getSelection();
} else if (document.selection) {
s = document.selection.createRange().text;
}
document.getElementById("phigita").setAttribute('selection', s);
return true;
},
getSelection: function(question) {
s = document.getElementById("phigita").getAttribute('selection');
if (s == '') {
if (typeof(question) != 'undefined' && question != '') {
s = prompt(question, '');
}
}
return s;
},
href: function(url) {
location.href = url;
},
toggle: function(id) {
part = document.getElementById("__phigita_" + id + "_part");
x = document.getElementById("__phigita_" + id);
if (part.style.display == "none") {
part.style.display = "block";
x.style.display = "none";
} else {
part.style.display = "none";
x.style.display = "block";
}
},
a: function(href, onclick) {
a = document.createElement("a");
a.setAttribute("href", href);
a.setAttribute("onclick", onclick);
return a;
},
selection: '',
settings: {
'id':'anon','preid':'','auth':'cd26b935f962b490a5f63d3fd839cec7','password':'f311e4555e49624b710df108ed4fcb95','email':'','email_challenge':'','email_confirmed':'0','width':'362','height':'130','left':'10','advanced':'0','opacity':'95','display_save':'0','only_moderated':'1','close':'2','favicons':'1','allow_view':'1','close_blummlet':'1','no_httpauth':'0','theme':'0','textcolor':'000','linkcolor':'28d524','bgcolor':'fff','bordercolor':'28d524','css':'','open_wiki':'0','wikiwidth':'200','wikiheight':'80','open_link':'0','last_login':'0000-00-00 00:00:00','ip':'','referer':'','last_used':'0000-00-00 00:00:00','created':'0000-00-00 00:00:00','expires':'0000-00-00 00:00:00','opacity64':'iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABGdBTUEAANbY1E9YMgAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAAwSURBVHja7M5BAQAABAQw9E+rwInhsyVYJ9l6NPVMQEBAQEBAQEBAQEBAQEDgBBgAfA0EL5uajmUAAAAASUVORK5CYII='
},
messages: [
"Consider a <a href='http://www.blummy.com/donate.php'>donation</a> if you like blummy.",
"Turn off the password query at <a href='http://www.blummy.com/prefs.php'>preferences</a>."
],
scrollInterval: null,
pos: -1
};
PHIGITA.init();
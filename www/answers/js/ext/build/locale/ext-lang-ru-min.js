/*
 * Ext JS Library 1.0.1
 * Copyright(c) 2006-2007, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://www.extjs.com/license
 */

Ext.UpdateManager.defaults.indicatorText="<div class=\"loading-indicator\">\xd0\u02dc\xd0\xb4\xd0\xb5\xd1\u201a \xd0\xb7\xd0\xb0\xd0\xb3\xd1\u20ac\xd1\u0192\xd0\xb7\xd0\xba\xd0\xb0...</div>";if(Ext.View){Ext.View.prototype.emptyText="";}if(Ext.grid.Grid){Ext.grid.Grid.prototype.ddText="{0} \xd0\xb2\xd1\u2039\xd0\xb1\xd1\u20ac\xd0\xb0\xd0\xbd\xd0\xbd\xd1\u2039\xd1\u2026 \xd1\ufffd\xd1\u201a\xd1\u20ac\xd0\xbe\xd0\xba";}if(Ext.TabPanelItem){Ext.TabPanelItem.prototype.closeText="\xd0\u2014\xd0\xb0\xd0\xba\xd1\u20ac\xd1\u2039\xd1\u201a\xd1\u0152 \xd1\ufffd\xd1\u201a\xd1\u0192 \xd0\xb2\xd0\xba\xd0\xbb\xd0\xb0\xd0\xb4\xd0\xba\xd1\u0192";}if(Ext.form.Field){Ext.form.Field.prototype.invalidText="\xd0\u2014\xd0\xbd\xd0\xb0\xd1\u2021\xd0\xb5\xd0\xbd\xd0\xb8\xd0\xb5 \xd0\xb2 \xd1\ufffd\xd1\u201a\xd0\xbe\xd0\xbc \xd0\xbf\xd0\xbe\xd0\xbb\xd0\xb5 \xd0\xbd\xd0\xb5\xd0\xb2\xd0\xb5\xd1\u20ac\xd0\xbd\xd0\xbe\xd0\xb5";}Date.monthNames=["\xd0\xaf\xd0\xbd\xd0\xb2\xd0\xb0\xd1\u20ac\xd1\u0152","\xd0\xa4\xd0\xb5\xd0\xb2\xd1\u20ac\xd0\xb0\xd0\xbb\xd1\u0152","\xd0\u0153\xd0\xb0\xd1\u20ac\xd1\u201a","\xd0\ufffd\xd0\xbf\xd1\u20ac\xd0\xb5\xd0\xbb\xd1\u0152","\xd0\u0153\xd0\xb0\xd0\xb9","\xd0\u02dc\xd1\u017d\xd0\xbd\xd1\u0152","\xd0\u02dc\xd1\u017d\xd0\xbb\xd1\u0152","\xd0\ufffd\xd0\xb2\xd0\xb3\xd1\u0192\xd1\ufffd\xd1\u201a","\xd0\xa1\xd0\xb5\xd0\xbd\xd1\u201a\xd1\ufffd\xd0\xb1\xd1\u20ac\xd1\u0152","\xd0\u017e\xd0\xba\xd1\u201a\xd1\ufffd\xd0\xb1\xd1\u20ac\xd1\u0152","\xd0\ufffd\xd0\xbe\xd1\ufffd\xd0\xb1\xd1\u20ac\xd1\u0152","\xd0\u201d\xd0\xb5\xd0\xba\xd0\xb0\xd0\xb1\xd1\u20ac\xd1\u0152"];Date.dayNames=["\xd0\u2019\xd0\xbe\xd1\ufffd\xd0\xba\xd1\u20ac\xd0\xb5\xd1\ufffd\xd0\xb5\xd0\xbd\xd1\u0152\xd0\xb5","\xd0\u0178\xd0\xbe\xd0\xbd\xd0\xb5\xd0\xb4\xd0\xb5\xd0\xbb\xd1\u0152\xd0\xbd\xd0\xb8\xd0\xba","\xd0\u2019\xd1\u201a\xd0\xbe\xd1\u20ac\xd0\xbd\xd0\xb8\xd0\xba","\xd0\xa1\xd1\u20ac\xd0\xb5\xd0\xb4\xd0\xb0","\xd0\xa7\xd0\xb5\xd1\u201a\xd0\xb2\xd0\xb5\xd1\u20ac\xd0\xb3","\xd0\u0178\xd1\ufffd\xd1\u201a\xd0\xbd\xd0\xb8\xd1\u2020\xd0\xb0","\xd0\xa1\xd1\u0192\xd0\xb1\xd0\xb1\xd0\xbe\xd1\u201a\xd0\xb0"];if(Ext.MessageBox){Ext.MessageBox.buttonText={ok:"OK",cancel:"\xd0\u017e\xd1\u201a\xd0\xbc\xd0\xb5\xd0\xbd\xd0\xb0",yes:"\xd0\u201d\xd0\xb0",no:"\xd0\ufffd\xd0\xb5\xd1\u201a"};}if(Ext.util.Format){Ext.util.Format.date=function(v,_2){if(!v){return "";}if(!(v instanceof Date)){v=new Date(Date.parse(v));}return v.dateFormat(_2||"d.m.Y");};}if(Ext.DatePicker){Ext.apply(Ext.DatePicker.prototype,{todayText:"\xd0\xa1\xd0\xb5\xd0\xb3\xd0\xbe\xd0\xb4\xd0\xbd\xd1\ufffd",minText:"\xd0\xd1\u201a\xd0\xb0 \xd0\xb4\xd0\xb0\xd1\u201a\xd0\xb0 \xd1\u20ac\xd0\xb0\xd0\xbd\xd1\u0152\xd1\u02c6\xd0\xb5 \xd0\xbc\xd0\xb8\xd0\xbd\xd0\xb8\xd0\xbc\xd0\xb0\xd0\xbb\xd1\u0152\xd0\xbd\xd0\xbe\xd0\xb9 \xd0\xb4\xd0\xb0\xd1\u201a\xd1\u2039",maxText:"\xd0\xd1\u201a\xd0\xb0 \xd0\xb4\xd0\xb0\xd1\u201a\xd0\xb0 \xd0\xbf\xd0\xbe\xd0\xb7\xd0\xb6\xd0\xb5 \xd0\xbc\xd0\xb0\xd0\xba\xd1\ufffd\xd0\xb8\xd0\xbc\xd0\xb0\xd0\xbb\xd1\u0152\xd0\xbd\xd0\xbe\xd0\xb9 \xd0\xb4\xd0\xb0\xd1\u201a\xd1\u2039",disabledDaysText:"",disabledDatesText:"",monthNames:Date.monthNames,dayNames:Date.dayNames,nextText:"\xd0\xa1\xd0\xbb\xd0\xb5\xd0\xb4\xd1\u0192\xd1\u017d\xd1\u2030\xd0\xb8\xd0\xb9 \xd0\xbc\xd0\xb5\xd1\ufffd\xd1\ufffd\xd1\u2020 (Control+\xd0\u2019\xd0\xbf\xd1\u20ac\xd0\xb0\xd0\xb2\xd0\xbe)",prevText:"\xd0\u0178\xd1\u20ac\xd0\xb5\xd0\xb4\xd1\u2039\xd0\xb4\xd1\u0192\xd1\u2030\xd0\xb8\xd0\xb9 \xd0\xbc\xd0\xb5\xd1\ufffd\xd1\ufffd\xd1\u2020 (Control+\xd0\u2019\xd0\xbb\xd0\xb5\xd0\xb2\xd0\xbe)",monthYearText:"\xd0\u2019\xd1\u2039\xd0\xb1\xd0\xbe\xd1\u20ac \xd0\xbc\xd0\xb5\xd1\ufffd\xd1\ufffd\xd1\u2020\xd0\xb0 (Control+\xd0\u2019\xd0\xb2\xd0\xb5\xd1\u20ac\xd1\u2026/\xd0\u2019\xd0\xbd\xd0\xb8\xd0\xb7 \xd0\xb4\xd0\xbb\xd1\ufffd \xd0\xb2\xd1\u2039\xd0\xb1\xd0\xbe\xd1\u20ac\xd0\xb0 \xd0\xb3\xd0\xbe\xd0\xb4\xd0\xb0)",todayTip:"{0} (\xd0\u0178\xd1\u20ac\xd0\xbe\xd0\xb1\xd0\xb5\xd0\xbb)",format:"d.m.y",startDay:1});}if(Ext.PagingToolbar){Ext.apply(Ext.PagingToolbar.prototype,{beforePageText:"\xd0\xa1\xd1\u201a\xd1\u20ac\xd0\xb0\xd0\xbd\xd0\xb8\xd1\u2020\xd0\xb0",afterPageText:"\xd0\xb8\xd0\xb7 {0}",firstText:"\xd0\u0178\xd0\xb5\xd1\u20ac\xd0\xb2\xd0\xb0\xd1\ufffd \xd1\ufffd\xd1\u201a\xd1\u20ac\xd0\xb0\xd0\xbd\xd0\xb8\xd1\u2020\xd0\xb0",prevText:"\xd0\u0178\xd1\u20ac\xd0\xb5\xd0\xb4\xd1\u2039\xd0\xb4\xd1\u0192\xd1\u2030\xd0\xb0\xd1\ufffd \xd1\ufffd\xd1\u201a\xd1\u20ac\xd0\xb0\xd0\xbd\xd0\xb8\xd1\u2020\xd0\xb0",nextText:"\xd0\xa1\xd0\xbb\xd0\xb5\xd0\xb4\xd1\u0192\xd1\u017d\xd1\u2030\xd0\xb0\xd1\ufffd \xd1\ufffd\xd1\u201a\xd1\u20ac\xd0\xb0\xd0\xbd\xd0\xb8\xd1\u2020\xd0\xb0",lastText:"\xd0\u0178\xd0\xbe\xd1\ufffd\xd0\xbb\xd0\xb5\xd0\xb4\xd0\xbd\xd1\ufffd\xd1\ufffd \xd1\ufffd\xd1\u201a\xd1\u20ac\xd0\xb0\xd0\xbd\xd0\xb8\xd1\u2020\xd0\xb0",refreshText:"\xd0\u017e\xd0\xb1\xd0\xbd\xd0\xbe\xd0\xb2\xd0\xb8\xd1\u201a\xd1\u0152",displayMsg:"\xd0\u017e\xd1\u201a\xd0\xbe\xd0\xb1\xd1\u20ac\xd0\xb0\xd0\xb6\xd0\xb0\xd1\u017d\xd1\u201a\xd1\ufffd\xd1\ufffd \xd0\xb7\xd0\xb0\xd0\xbf\xd0\xb8\xd1\ufffd\xd0\xb8 \xd1\ufffd {0} \xd0\xbf\xd0\xbe {1}, \xd0\xb2\xd1\ufffd\xd0\xb5\xd0\xb3\xd0\xbe {2}",emptyMsg:"\xd0\ufffd\xd0\xb5\xd1\u201a \xd0\xb4\xd0\xb0\xd0\xbd\xd0\xbd\xd1\u2039\xd1\u2026 \xd0\xb4\xd0\xbb\xd1\ufffd \xd0\xbe\xd1\u201a\xd0\xbe\xd0\xb1\xd1\u20ac\xd0\xb0\xd0\xb6\xd0\xb5\xd0\xbd\xd0\xb8\xd1\ufffd"});}if(Ext.form.TextField){Ext.apply(Ext.form.TextField.prototype,{minLengthText:"\xd0\u0153\xd0\xb8\xd0\xbd\xd0\xb8\xd0\xbc\xd0\xb0\xd0\xbb\xd1\u0152\xd0\xbd\xd0\xb0\xd1\ufffd \xd0\xb4\xd0\xbb\xd0\xb8\xd0\xbd\xd0\xb0 \xd1\ufffd\xd1\u201a\xd0\xbe\xd0\xb3\xd0\xbe \xd0\xbf\xd0\xbe\xd0\xbb\xd1\ufffd {0}",maxLengthText:"\xd0\u0153\xd0\xb0\xd0\xba\xd1\ufffd\xd0\xb8\xd0\xbc\xd0\xb0\xd0\xbb\xd1\u0152\xd0\xbd\xd0\xb0\xd1\ufffd \xd0\xb4\xd0\xbb\xd0\xb8\xd0\xbd\xd0\xb0 \xd1\ufffd\xd1\u201a\xd0\xbe\xd0\xb3\xd0\xbe \xd0\xbf\xd0\xbe\xd0\xbb\xd1\ufffd {0}",blankText:"\xd0\xd1\u201a\xd0\xbe \xd0\xbf\xd0\xbe\xd0\xbb\xd0\xb5 \xd0\xbe\xd0\xb1\xd1\ufffd\xd0\xb7\xd0\xb0\xd1\u201a\xd0\xb5\xd0\xbb\xd1\u0152\xd0\xbd\xd0\xbe \xd0\xb4\xd0\xbb\xd1\ufffd \xd0\xb7\xd0\xb0\xd0\xbf\xd0\xbe\xd0\xbb\xd0\xbd\xd0\xb5\xd0\xbd\xd0\xb8\xd1\ufffd",regexText:"",emptyText:null});}if(Ext.form.NumberField){Ext.apply(Ext.form.NumberField.prototype,{minText:"\xd0\u2014\xd0\xbd\xd0\xb0\xd1\u2021\xd0\xb5\xd0\xbd\xd0\xb8\xd0\xb5 \xd1\ufffd\xd1\u201a\xd0\xbe\xd0\xb3\xd0\xbe \xd0\xbf\xd0\xbe\xd0\xbb\xd1\ufffd \xd0\xbd\xd0\xb5 \xd0\xbc\xd0\xbe\xd0\xb6\xd0\xb5\xd1\u201a \xd0\xb1\xd1\u2039\xd1\u201a\xd1\u0152 \xd0\xbc\xd0\xb5\xd0\xbd\xd1\u0152\xd1\u02c6\xd0\xb5 {0}",maxText:"\xd0\u2014\xd0\xbd\xd0\xb0\xd1\u2021\xd0\xb5\xd0\xbd\xd0\xb8\xd0\xb5 \xd1\ufffd\xd1\u201a\xd0\xbe\xd0\xb3\xd0\xbe \xd0\xbf\xd0\xbe\xd0\xbb\xd1\ufffd \xd0\xbd\xd0\xb5 \xd0\xbc\xd0\xbe\xd0\xb6\xd0\xb5\xd1\u201a \xd0\xb1\xd1\u2039\xd1\u201a\xd1\u0152 \xd0\xb1\xd0\xbe\xd0\xbb\xd1\u0152\xd1\u02c6\xd0\xb5 {0}",nanText:"{0} \xd0\xbd\xd0\xb5 \xd1\ufffd\xd0\xb2\xd0\xbb\xd1\ufffd\xd0\xb5\xd1\u201a\xd1\ufffd\xd1\ufffd \xd1\u2021\xd0\xb8\xd1\ufffd\xd0\xbb\xd0\xbe\xd0\xbc"});}if(Ext.form.DateField){Ext.apply(Ext.form.DateField.prototype,{disabledDaysText:"\xd0\ufffd\xd0\xb5 \xd0\xb4\xd0\xbe\xd1\ufffd\xd1\u201a\xd1\u0192\xd0\xbf\xd0\xbd\xd0\xbe",disabledDatesText:"\xd0\ufffd\xd0\xb5 \xd0\xb4\xd0\xbe\xd1\ufffd\xd1\u201a\xd1\u0192\xd0\xbf\xd0\xbd\xd0\xbe",minText:"\xd0\u201d\xd0\xb0\xd1\u201a\xd0\xb0 \xd0\xb2 \xd1\ufffd\xd1\u201a\xd0\xbe\xd0\xbc \xd0\xbf\xd0\xbe\xd0\xbb\xd0\xb5 \xd0\xb4\xd0\xbe\xd0\xbb\xd0\xb6\xd0\xbd\xd0\xb0 \xd0\xb1\xd1\u2039\xd1\u201a\xd1\u0152 \xd0\xbf\xd0\xbe\xd0\xb7\xd0\xb4\xd0\xb5 {0}",maxText:"\xd0\u201d\xd0\xb0\xd1\u201a\xd0\xb0 \xd0\xb2 \xd1\ufffd\xd1\u201a\xd0\xbe\xd0\xbc \xd0\xbf\xd0\xbe\xd0\xbb\xd0\xb5 \xd0\xb4\xd0\xbe\xd0\xbb\xd0\xb6\xd0\xbd\xd0\xb0 \xd0\xb1\xd1\u2039\xd1\u201a\xd1\u0152 \xd1\u20ac\xd0\xb0\xd0\xbd\xd1\u0152\xd1\u02c6\xd0\xb5 {0}",invalidText:"{0} \xd0\xbd\xd0\xb5 \xd1\ufffd\xd0\xb2\xd0\xbb\xd1\ufffd\xd0\xb5\xd1\u201a\xd1\ufffd\xd1\ufffd \xd0\xbf\xd1\u20ac\xd0\xb0\xd0\xb2\xd0\xb8\xd0\xbb\xd1\u0152\xd0\xbd\xd0\xbe\xd0\xb9 \xd0\xb4\xd0\xb0\xd1\u201a\xd0\xbe\xd0\xb9 - \xd0\xb4\xd0\xb0\xd1\u201a\xd0\xb0 \xd0\xb4\xd0\xbe\xd0\xbb\xd0\xb6\xd0\xbd\xd0\xb0 \xd0\xb1\xd1\u2039\xd1\u201a\xd1\u0152 \xd1\u0192\xd0\xba\xd0\xb0\xd0\xb7\xd0\xb0\xd0\xbd\xd0\xb0 \xd0\xb2 \xd1\u201e\xd0\xbe\xd1\u20ac\xd0\xbc\xd0\xb0\xd1\u201a\xd0\xb5 {1}",format:"d.m.y"});}if(Ext.form.ComboBox){Ext.apply(Ext.form.ComboBox.prototype,{loadingText:"\xd0\u2014\xd0\xb0\xd0\xb3\xd1\u20ac\xd1\u0192\xd0\xb7\xd0\xba\xd0\xb0...",valueNotFoundText:undefined});}if(Ext.form.VTypes){Ext.apply(Ext.form.VTypes,{emailText:"\xd0\xd1\u201a\xd0\xbe \xd0\xbf\xd0\xbe\xd0\xbb\xd0\xb5 \xd0\xb4\xd0\xbe\xd0\xbb\xd0\xb6\xd0\xbd\xd0\xbe \xd1\ufffd\xd0\xbe\xd0\xb4\xd0\xb5\xd1\u20ac\xd0\xb6\xd0\xb0\xd1\u201a\xd1\u0152 \xd0\xb0\xd0\xb4\xd1\u20ac\xd0\xb5\xd1\ufffd \xd1\ufffd\xd0\xbb\xd0\xb5\xd0\xba\xd1\u201a\xd1\u20ac\xd0\xbe\xd0\xbd\xd0\xbd\xd0\xbe\xd0\xb9 \xd0\xbf\xd0\xbe\xd1\u2021\xd1\u201a\xd1\u2039 \xd0\xb2 \xd1\u201e\xd0\xbe\xd1\u20ac\xd0\xbc\xd0\xb0\xd1\u201a\xd0\xb5 \"user@domain.com\"",urlText:"\xd0\xd1\u201a\xd0\xbe \xd0\xbf\xd0\xbe\xd0\xbb\xd0\xb5 \xd0\xb4\xd0\xbe\xd0\xbb\xd0\xb6\xd0\xbd\xd0\xbe \xd1\ufffd\xd0\xbe\xd0\xb4\xd0\xb5\xd1\u20ac\xd0\xb6\xd0\xb0\xd1\u201a\xd1\u0152 URL \xd0\xb2 \xd1\u201e\xd0\xbe\xd1\u20ac\xd0\xbc\xd0\xb0\xd1\u201a\xd0\xb5 \"http:/"+"/www.domain.com\"",alphaText:"\xd0\xd1\u201a\xd0\xbe \xd0\xbf\xd0\xbe\xd0\xbb\xd0\xb5 \xd0\xb4\xd0\xbe\xd0\xbb\xd0\xb6\xd0\xbd\xd0\xbe \xd1\ufffd\xd0\xbe\xd0\xb4\xd0\xb5\xd1\u20ac\xd0\xb6\xd0\xb0\xd1\u201a\xd1\u0152 \xd1\u201a\xd0\xbe\xd0\xbb\xd1\u0152\xd0\xba\xd0\xbe \xd0\xbb\xd0\xb0\xd1\u201a\xd0\xb8\xd0\xbd\xd1\ufffd\xd0\xba\xd0\xb8\xd0\xb5 \xd0\xb1\xd1\u0192\xd0\xba\xd0\xb2\xd1\u2039 \xd0\xb8 \xd1\ufffd\xd0\xb8\xd0\xbc\xd0\xb2\xd0\xbe\xd0\xbb \xd0\xbf\xd0\xbe\xd0\xb4\xd1\u2021\xd0\xb5\xd1\u20ac\xd0\xba\xd0\xb8\xd0\xb2\xd0\xb0\xd0\xbd\xd0\xb8\xd1\ufffd \"_\"",alphanumText:"\xd0\xd1\u201a\xd0\xbe \xd0\xbf\xd0\xbe\xd0\xbb\xd0\xb5 \xd0\xb4\xd0\xbe\xd0\xbb\xd0\xb6\xd0\xbd\xd0\xbe \xd1\ufffd\xd0\xbe\xd0\xb4\xd0\xb5\xd1\u20ac\xd0\xb6\xd0\xb0\xd1\u201a\xd1\u0152 \xd1\u201a\xd0\xbe\xd0\xbb\xd1\u0152\xd0\xba\xd0\xbe \xd0\xbb\xd0\xb0\xd1\u201a\xd0\xb8\xd0\xbd\xd1\ufffd\xd0\xba\xd0\xb8\xd0\xb5 \xd0\xb1\xd1\u0192\xd0\xba\xd0\xb2\xd1\u2039, \xd1\u2020\xd0\xb8\xd1\u201e\xd1\u20ac\xd1\u2039 \xd0\xb8 \xd1\ufffd\xd0\xb8\xd0\xbc\xd0\xb2\xd0\xbe\xd0\xbb \xd0\xbf\xd0\xbe\xd0\xb4\xd1\u2021\xd0\xb5\xd1\u20ac\xd0\xba\xd0\xb8\xd0\xb2\xd0\xb0\xd0\xbd\xd0\xb8\xd1\ufffd \"_\""});}if(Ext.grid.GridView){Ext.apply(Ext.grid.GridView.prototype,{sortAscText:"\xd0\xa1\xd0\xbe\xd1\u20ac\xd1\u201a\xd0\xb8\xd1\u20ac\xd0\xbe\xd0\xb2\xd0\xb0\xd1\u201a\xd1\u0152 \xd0\xbf\xd0\xbe \xd0\xb2\xd0\xbe\xd0\xb7\xd1\u20ac\xd0\xb0\xd1\ufffd\xd1\u201a\xd0\xb0\xd0\xbd\xd0\xb8\xd1\u017d",sortDescText:"\xd0\xa1\xd0\xbe\xd1\u20ac\xd1\u201a\xd0\xb8\xd1\u20ac\xd0\xbe\xd0\xb2\xd0\xb0\xd1\u201a\xd1\u0152 \xd0\xbf\xd0\xbe \xd1\u0192\xd0\xb1\xd1\u2039\xd0\xb2\xd0\xb0\xd0\xbd\xd0\xb8\xd1\u017d",lockText:"\xd0\u2014\xd0\xb0\xd0\xba\xd1\u20ac\xd0\xb5\xd0\xbf\xd0\xb8\xd1\u201a\xd1\u0152 \xd1\ufffd\xd1\u201a\xd0\xbe\xd0\xbb\xd0\xb1\xd0\xb5\xd1\u2020",unlockText:"\xd0\xa1\xd0\xbd\xd1\ufffd\xd1\u201a\xd1\u0152 \xd0\xb7\xd0\xb0\xd0\xba\xd1\u20ac\xd0\xb5\xd0\xbf\xd0\xbb\xd0\xb5\xd0\xbd\xd0\xb8\xd0\xb5 \xd1\ufffd\xd1\u201a\xd0\xbe\xd0\xbb\xd0\xb1\xd1\u2020\xd0\xb0",columnsText:"\xd0\xa1\xd1\u201a\xd0\xbe\xd0\xbb\xd0\xb1\xd1\u2020\xd1\u2039"});}if(Ext.grid.PropertyColumnModel){Ext.apply(Ext.grid.PropertyColumnModel.prototype,{nameText:"\xd0\ufffd\xd0\xb0\xd0\xb7\xd0\xb2\xd0\xb0\xd0\xbd\xd0\xb8\xd0\xb5",valueText:"\xd0\u2014\xd0\xbd\xd0\xb0\xd1\u2021\xd0\xb5\xd0\xbd\xd0\xb8\xd0\xb5",dateFormat:"j.m.Y"});}if(Ext.SplitLayoutRegion){Ext.apply(Ext.SplitLayoutRegion.prototype,{splitTip:"\xd0\xa2\xd1\ufffd\xd0\xbd\xd0\xb8\xd1\u201a\xd0\xb5 \xd0\xb4\xd0\xbb\xd1\ufffd \xd0\xb8\xd0\xb7\xd0\xbc\xd0\xb5\xd0\xbd\xd0\xb5\xd0\xbd\xd0\xb8\xd1\ufffd \xd1\u20ac\xd0\xb0\xd0\xb7\xd0\xbc\xd0\xb5\xd1\u20ac\xd0\xb0.",collapsibleSplitTip:"\xd0\xa2\xd1\ufffd\xd0\xbd\xd0\xb8\xd1\u201a\xd0\xb5 \xd0\xb4\xd0\xbb\xd1\ufffd \xd0\xb8\xd0\xb7\xd0\xbc\xd0\xb5\xd0\xbd\xd0\xb5\xd0\xbd\xd0\xb8\xd1\ufffd \xd1\u20ac\xd0\xb0\xd0\xb7\xd0\xbc\xd0\xb5\xd1\u20ac\xd0\xb0. \xd0\u201d\xd0\xb2\xd0\xbe\xd0\xb9\xd0\xbd\xd0\xbe\xd0\xb9 \xd1\u2030\xd0\xb5\xd0\xbb\xd1\u2021\xd0\xbe\xd0\xba \xd1\ufffd\xd0\xbf\xd1\u20ac\xd1\ufffd\xd1\u2021\xd0\xb5\xd1\u201a \xd0\xbf\xd0\xb0\xd0\xbd\xd0\xb5\xd0\xbb\xd1\u0152."});}

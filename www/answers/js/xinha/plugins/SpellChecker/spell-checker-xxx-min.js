
HTMLArea.Config.prototype.SpellChecker={'backend':'php','personalFilesDir':'','defaultDictionary':'en_GB','utf8_to_entities':true};function SpellChecker(editor){this.editor=editor;var cfg=editor.config;var bl=SpellChecker.btnList;var self=this;var id="SC-spell-check";cfg.registerButton(id,this._lc("Spell-check"),editor.imgURL("spell-check.gif","SpellChecker"),false,function(editor,id){self.buttonPress(editor,id);});cfg.addToolbarElement("SC-spell-check","htmlmode",1);}
SpellChecker._pluginInfo={name:"SpellChecker",version:"1.0",developer:"Mihai Bazon",developer_url:"http://dynarch.com/mishoo/",c_owner:"Mihai Bazon",sponsor:"American Bible Society",sponsor_url:"http://www.americanbible.org",license:"htmlArea"};SpellChecker.prototype._lc=function(string){return HTMLArea._lc(string,'SpellChecker');};SpellChecker.btnList=[null,["spell-check"]];SpellChecker.prototype.buttonPress=function(editor,id){switch(id){case"SC-spell-check":SpellChecker.editor=editor;SpellChecker.init=true;var uiurl=_editor_url+"plugins/SpellChecker/spell-check-ui.html";var win;if(HTMLArea.is_ie){win=window.open(uiurl,"SC_spell_checker","toolbar=no,location=no,directories=no,status=no,menubar=no,"+"scrollbars=no,resizable=yes,width=600,height=450");}else{win=window.open(uiurl,"SC_spell_checker","toolbar=no,menubar=no,personalbar=no,width=600,height=450,"+"scrollbars=no,resizable=yes");}
win.focus();break;}};SpellChecker.editor=null;

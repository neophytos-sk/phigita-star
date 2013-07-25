
Wikiwyg.uri=function(){var uri=location.protocol+'//'+location.host+':'+
location.port+'/server/index.cgi';if(!uri.match(/phigita\.net/))
alert("This only works on phigita.net");return uri;}
proto=new Subclass('Wikiwyg.ClientServer','Wikiwyg');proto.saveChanges=function(oBody){var self=this;this.current_mode.toHtml(function(html){self.fromHtml(html)});self=this.mode_objects['Wikiwyg.Wikitext.ClientServer'];self.fromHtml(this.div.innerHTML);oBody.value='\n'+self.toWikitext();}
proto.testChanges=function(oBody){var self=this;self.switchMode('Wikiwyg.Wikitext.ClientServer');oBody.value=self.current_mode.textarea.value;}
proto.modeClasses=['Wikiwyg.Wysiwyg','Wikiwyg.Wikitext.ClientServer'];proto=new Subclass('Wikiwyg.Wikitext.ClientServer','Wikiwyg.Wikitext');proto.convertWikitextToHtml=function(wikitext,func){var postdata='action=wikiwyg_wikitext_to_html;content='+
encodeURIComponent(wikitext);Wikiwyg.liveUpdate('POST',Wikiwyg.uri(),postdata,func);}

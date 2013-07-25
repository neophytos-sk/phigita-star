
function addEvent(elm,evType,fn,useCapture){if(elm.addEventListener){elm.addEventListener(evType,fn,useCapture);return true;}else if(elm.attachEvent){var r=elm.attachEvent('on'+evType,fn);return r;}else{elm['on'+evType]=fn;}}
var LIVE_SEARCH_PROMPT="live search...";var COLUMN_ORDER=0;var COLOR_SET=1;var LAYOUT=2
var user_prefs=new Array('c-ms','cs1','fixed');var results_displayed=false;var sliding=false;var search_focused=false;var isSafari=((parseInt(navigator.productSub)>=20020000)&&(navigator.vendor.indexOf("Apple Computer")!=-1));function iq_format_search_field(){if(!document.getElementById)return;var text_field=document.getElementById('q');text_field.setAttribute("type","hidden");search_field=document.createElement('INPUT');if(isSafari){search_field.setAttribute('id','q_proxy_safari');search_field.setAttribute('type','search');search_field.setAttribute('results','5');search_field.setAttribute('placeholder',LIVE_SEARCH_PROMPT);search_field.setAttribute('autosave','typo-search');}else{search_field.setAttribute('id','q_proxy');search_field.setAttribute('type','text');if(search_field.value=='')search_field.value=LIVE_SEARCH_PROMPT;}
addEvent(search_field,'focus',iq_focus_search,false);addEvent(search_field,'blur',iq_blur_search,false);addEvent(search_field,'keyup',iq_copy_search_value,false);addEvent(search_field,'blur',iq_copy_search_value,false);text_field.parentNode.insertBefore(search_field,text_field);}
function iq_copy_search_value(){var text_field=document.getElementById('q');text_field.value=(this.value==LIVE_SEARCH_PROMPT)?'':this.value;}
function iq_focus_search(){if(!isSafari&&this.value==LIVE_SEARCH_PROMPT){this.value='';}
search_focused=true;this.setAttribute('class','active');if(this.value!='')showSearch();}
function iq_blur_search(){if(!isSafari&&this.value==''){this.value=LIVE_SEARCH_PROMPT;}
search_focused=false;this.removeAttribute('class','active');}
function iq_switch_to_fixed(){iq_switch_pref(LAYOUT,'fixed');}
function iq_switch_to_fluid(){iq_switch_pref(LAYOUT,'fluid');}
function iq_switch_to_cs0(){iq_switch_pref(COLOR_SET,'cs0');}
function iq_switch_to_cs1(){iq_switch_pref(COLOR_SET,'cs1');}
function iq_switch_to_cs2(){iq_switch_pref(COLOR_SET,'cs2');}
function iq_switch_pref(pref,layout){user_prefs[pref]=layout;if($('theme-panel').style.display!='none')Effect.BlindLeftIn('theme-panel');iq_set_body_class();}
function iq_set_body_class(){document.getElementsByTagName('body')[0].className=user_prefs.join(' ');}
function iq_add_layout_switcher(){}
function showSearch(){Element.hide('search_spinner');if($('q').value==''){$('search-close').style.display='none';$('search-results').style.display='none';results_displayed=false;}else{revealSearch();}}
function revealSearch(){if(sliding==false&&results_displayed==true)return;Effect.SlideDown('search-results',{beforeStart:function(){sliding=true;},afterFinish:function(){sliding=false;results_displayed=true;Effect.Appear('search-close');}});}
function closeSearch(){$('search-close').style.display='none';$('search-results').style.display='none';results_displayed=false;return;if(results_displayed&&!search_focused){Effect.Fade('search-close');Effect.SlideUp('search-results',{beforeStart:function(){sliding=true;Effect.Fade('search-close');},afterFinish:function(){sliding=false;results_displayed=false;}})}}
Effect.BlindLeftIn=function(element){Element.makeClipping(element);new Effect.Scale(element,0,Object.extend({scaleContent:false,scaleY:false,afterFinish:function(effect)
{Element.hide(effect.element);Element.undoClipping(effect.element);}},arguments[1]||{}));}
Effect.BlindLeftOut=function(element){$(element).style.width='0px';Element.makeClipping(element);Element.show(element);new Effect.Scale(element,100,Object.extend({scaleContent:false,scaleY:false,scaleMode:'contents',scaleFrom:0,afterFinish:function(effect){Element.undoClipping(effect.element);}},arguments[1]||{}));}
function iq_toggle_options(){if($('theme-panel').style.display!='none'){Effect.BlindLeftIn('theme-panel');}else{Effect.BlindLeftOut('theme-panel');}}
addEvent(window,'load',iq_format_search_field,false);

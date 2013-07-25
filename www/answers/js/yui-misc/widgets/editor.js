YAHOO.widget.Editor = {
    config: {
        _timerContent: null,
        editor: false,
	blank_uri: null,
        debug: YAHOO.util.Dom.get('debug'),
        preText: false,
        colors: [
          '000000', '111111', '2d2d2d', '434343', '5b5b5b', '737373',
          '8b8b8b', 'a2a2a2', 'b9b9b9', 'd0d0d0', 'e6e6e6', 'ffffff',
          '7f7f00', 'bfbf00', 'ffff00', 'ffff40', 'ffff80', 'ffffbf', 
          '525330', '898a49', 'aea945', 'c3be71', 'e0dcaa', 'fcfae1',
          '407f00', '60bf00', '80ff00', 'a0ff40', 'c0ff80', 'dfffbf',
          '3b5738', '668f5a', '7f9757', '8a9b55', 'b7c296', 'e6ebd5',
          '007f40', '00bf60', '00ff80', '40ffa0', '80ffc0', 'bfffdf',
          '033d21', '438059', '7fa37c', '8dae94', 'acc6b5', 'ddebe2',
          '007f7f', '00bfbf', '00ffff', '40ffff', '80ffff', 'bfffff',
          '033d3d', '347d7e', '609a9f', '96bdc4', 'b5d1d7', 'e2f1f4',
          '00407f', '0060bf', '0080ff', '40a0ff', '80c0ff', 'bfdfff',
          '1b2c48', '385376', '57708f', '7792ac', 'a8bed1', 'deebf6',
          '00007f', '0000bf', '0000ff', '4040ff', '8080ff', 'bfbfff',
          '212143', '373e68', '444f75', '585e82', '8687a4', 'd2d1e1',
          '40007f', '6000bf', '8000ff', 'a040ff', 'c080ff', 'dfbfff',
          '302449', '54466f', '655a7f', '726284', '9e8fa9', 'dcd1df',
          '7f007f', 'bf00bf', 'ff00ff', 'ff40ff', 'ff80ff', 'ffbfff',
          '4a234a', '794a72', '936386', '9d7292', 'c0a0b6', 'ecdae5',
          '7f003f', 'bf005f', 'ff007f', 'ff409f', 'ff80bf', 'ffbfdf',
          '451528', '823857', 'a94a76', 'bc6f95', 'd8a5bb', 'f7dde9',
          '800000', 'c00000', 'ff0000', 'ff4040', 'ff8080', 'ffc0c0',
          '441415', '82393c', 'aa4d4e', 'bc6e6e', 'd8a3a4', 'f8dddd',
          '7f3f00', 'bf5f00', 'ff7f00', 'ff9f40', 'ffbf80', 'ffdfbf',
          '482c1b', '855a40', 'b27c51', 'c49b71', 'e1c4a8', 'fdeee0'
          ],
        emot_alts: [':)', ':(', ';)', ':D', ';;)',':-/', ':x', ':&quot;&gt;', ':p', ':*',':O', 'X-(', ':&gt;', 'B-)', ':-s','&gt;:)', ':((', ':))', ':|', '/:)','O:)', ':-B', '=;', 'I-)', '8-|',':-&amp;', ':-$', '[-(', ':o)', '8-}', '(:|', '=P~', ':-?', '#-o', '=D&gt;'],
        emots: ['01', '02', '03', '04', '05','06', '07', '08', '09', '10','11', '12', '13', '14', '15','16', '17', '18', '19', '20','21', '22', '23', '24', '25','26', '27', '28', '29', '30','31', '32', '33', '34', '35','37', '39', '40', '47', '50' ],
        menu_status: ['menu_backcolor'],
        events: ['click','dblclick','mousedown','mouseup','keypress','keydown','keyup'],
        disabled: ['anchor', 'unlink', 'forecolor', 'backcolor']
    },
    init: function(txtArea,blank_uri) {
	this.config.blank_uri=blank_uri;
        this.config.editor = YAHOO.util.Dom.get(txtArea);
        if (!this.config.editor) {
            alert('Error, no form field');
            return false;
        }
        if (this.config.editor.value) {
            this.config.preText = this.config.editor.value;
        }
        this._createControls();
        setTimeout(YAHOO.widget.Editor._setup, 5000);
    },
    _assignListeners: function() {
        var as = YAHOO.util.Dom.getElementsBy(function(elm) {
            if (elm.id.substring(0, 8) == 'toolbar_') {
                return true;
            } else {
                return false;
            }
        }, 'a', 'toolbar_1');
        var arr = [];
        for (var i = 0; i < as.length; i++) {
            if ((as[i].id != 'toolbar_forecolor') && (as[i].id != 'toolbar_backcolor') && (as[i].id != 'toolbar_smiley')) {
                arr[arr.length] = as[i].id;
            }
        }
        //Toolbar Listeners
        YAHOO.util.Event.addListener(arr, 'click', YAHOO.widget.Editor._execCommand, YAHOO.widget.Editor, true);

        //Menus
//        YAHOO.util.Event.addListener('toolbar_forecolor', 'click', YAHOO.widget.Editor._showMenu, YAHOO.widget.Editor, true);
        YAHOO.util.Event.addListener('toolbar_backcolor', 'click', YAHOO.widget.Editor._showMenu, YAHOO.widget.Editor, true);
//        YAHOO.util.Event.addListener('toolbar_smiley', 'click', YAHOO.widget.Editor._showMenu, YAHOO.widget.Editor, true);
        
        //DropDowns
//        YAHOO.util.Event.addListener('fontface_select', 'click', YAHOO.widget.Editor._showSelect, YAHOO.widget.Editor, true);
//        YAHOO.util.Event.addListener('fontsize_select', 'click', YAHOO.widget.Editor._showSelect, YAHOO.widget.Editor, true);

        //iFrame Doc
        for (i in this.config.events) {
            YAHOO.util.Event.addListener(this._doc(), this.config.events[i], YAHOO.widget.Editor._nodeChange, YAHOO.widget.Editor, true);
        }

    },
    _updateToolbar: function(arr) {
        var one = YAHOO.util.Dom.get('toolbar_1').getElementsByTagName('a');
        var sel = this._getSelection();
        YAHOO.util.Dom.replaceClass(one, 'yui_button_sel', 'yui_button');

        if (arr.length) {
            for (var i = 0; i < arr.length; i++) {
                if (YAHOO.util.Dom.get('toolbar_' + arr[i])) {
                    YAHOO.util.Dom.replaceClass('toolbar_' + arr[i], 'yui_button', 'yui_button_sel');
                }
            }
        }
        if (sel != '') {
            for (var i = 0; i < this.config.disabled.length; i++) {
                YAHOO.util.Dom.replaceClass('toolbar_' + this.config.disabled[i], 'yui_button_disable', 'yui_button');
            }
        } else {
            for (var i = 0; i < this.config.disabled.length; i++) {
                YAHOO.util.Dom.replaceClass('toolbar_' + this.config.disabled[i], 'yui_button_sel', 'yui_button_disable');
                YAHOO.util.Dom.replaceClass('toolbar_' + this.config.disabled[i], 'yui_button', 'yui_button_disable');
            }
        }
    },
    _nodeChange: function(ev) {
        var tar = YAHOO.util.Event.getTarget(ev, 1);
        var proc = true;
        var actions = [];
        var sel = this._getSelection();
        var tag = tar.tagName.toLowerCase();

        this.config.debug = false;
        if (this.config.debug) {
            arr = [];
            arr[arr.length] = 'Bold: ' + this._doc().queryCommandValue('bold');
            arr[arr.length] = 'Italic: ' + this._doc().queryCommandValue('italic');
            for (var i = 0; i < arr.length; i++) {
                var p = YAHOO.util.Dom.create('p', arr[i]);
                if (this.config.debug.firstChild) {
                    this.config.debug.insertBefore(p, this.config.debug.firstChild);
                } else {
                    this.config.debug.appendChild(p);
                }
            }
        }
        //Lists
        switch (tag) {
            case 'b':
            case 'strong':
                actions[actions.length] = 'bold';
                break;
            case 'i':
            case 'em':
                actions[actions.length] = 'italic';
                break;
            case 'u':
                actions[actions.length] = 'underline';
                break;
            case 'li':
                actions[actions.length] = tar.parentNode.tagName.toLowerCase();
                var str = 'List: ' + tar.parentNode.tagName.toLowerCase();
                var p = YAHOO.util.Dom.create('p', str);
                this.config.debug.insertBefore(p, this.config.debug.firstChild);
                break;
        }

        //Bold
        if (tar.style.fontWeight) {
            if (tar.style.fontWeight == 'bold') {
                actions[actions.length] = 'bold';
            }
        }
        
        //Italic
        if (tar.style.fontStyle) {
            if (tar.style.fontStyle == 'italic') {
                actions[actions.length] = 'italic';
            }
        }
        
        //Underline
        if (tar.style.textDecoration) {
            if (tar.style.textDecoration == 'underline') {
                actions[actions.length] = 'underline';
            }
        }
        
        //Alignment
//        actions[actions.length] = 'justify' + this._doc().queryCommandValue('justifycenter');
        
        //FontName
//        var name = this._doc().queryCommandValue('FontName');
//        YAHOO.util.Dom.get('fontface_select').firstChild.innerHTML = ((name) ? name : 'Verdana');
        //FontSize
//        var size = this._doc().queryCommandValue('FontSize');
//        YAHOO.util.Dom.get('fontsize_select').firstChild.innerHTML = ((size) ? size : '2');

        this._updateToolbar(actions);
        

    },
    _changeFont: function(ev) {
        var tar = YAHOO.util.Event.getTarget(ev).parentNode.parentNode;
        
        if (YAHOO.util.Event.getTarget(ev).parentNode.parentNode.id == 'fontsize') {
            var font = YAHOO.util.Event.getTarget(ev).parentNode.style.fontSize;
            for (var i = 0; i < this.config.fontsizes.length; i++) {
                if (this.config.fontsizes[i] == font) {
                    font = i + 1;
                    break;
                }
            }
            var action = 'fontsize';
        } else {
            var font = this._removeQuotes(YAHOO.util.Event.getTarget(ev).parentNode.style.fontFamily);
            var action = 'fontname';
        }
        
        tar.parentNode.firstChild.innerHTML = font;
        
        this._showSelect('', tar);
        
        //Change Font
        this._execCommand('', action, font);
        YAHOO.util.Event.stopEvent(ev);
    },
    _removeQuotes: function(str) {
        var checkText   = new String(str);
        var regEx1      = /\"/g;
        checkText       = String(checkText.replace(regEx1, ''));
        return checkText;
    },
    _hideMenus: function(state, tar) {
        if (state == 'none') {
            //opening, hide others
            for (var i in this.config.menu_status) {
                if (this.config.menu_status[i] == true) {
                    this.config.menu_status[i] = false;
                    YAHOO.util.Dom.setStyle(i, 'display', 'none');
                }
            }
            if (tar) {
                this.config.menu_status[tar.id] = true;
            }
        } else {
            if (tar) {
                this.config.menu_status[tar.id] = false;
            }
        }
    },
    _showSelect: function(ev, tar) {
        if (ev) {
            var tar = YAHOO.util.Event.getTarget(ev).getElementsByTagName('ul')[0];
            if (!tar) {
                var tar = YAHOO.util.Event.getTarget(ev).parentNode.getElementsByTagName('ul')[0];
            }
        }
        var state = YAHOO.util.Dom.getStyle(tar, 'display');
        
        this._hideMenus(state, tar);
        
        as = tar.getElementsByTagName('a');
        
        for (var i = 0; i < as.length; i++) {
            if (state == 'none') {
                YAHOO.util.Event.addListener(as[i], 'click', YAHOO.widget.Editor._changeFont, YAHOO.widget.Editor, true);
            } else {
                YAHOO.util.Event.removeListener(as[i], 'click', YAHOO.widget.Editor._changeFont);
            }
        }
        
        YAHOO.util.Dom.setStyle(tar, 'display', ((state == 'block') ? 'none' : 'block'));
        
        
        
        if (ev) {
            YAHOO.util.Event.stopEvent(ev);
        }
    },
    _showMenu: function(ev, tar) {
        if (ev) {
            var tar = YAHOO.util.Event.getTarget(ev).firstChild;
        }
        if (!ev && !tar) {
            return false;
        }
        var state = YAHOO.util.Dom.getStyle(tar, 'display');
        
        this._hideMenus(state, tar);
        
        if (tar && tar.id && (tar.id == 'menu_smiley')) {
            //Smilies
            imgs = tar.getElementsByTagName('img');
            if (state == 'none') {
                YAHOO.util.Event.addListener(imgs, 'click', YAHOO.widget.Editor._insertEmot, YAHOO.widget.Editor, true);
            } else {
                YAHOO.util.Event.removeListener(imgs, 'click', YAHOO.widget.Editor._insertEmot);
            }
        } else {
            //Colors
            var lis = YAHOO.util.Dom.getElementsBy(function(elm) {
                if (elm.className.substring(0, 6) == 'color_') {
                    return true;
                } else {
                    return false;
                }
            }, 'li', tar);
            if (state == 'none') {
                YAHOO.util.Event.addListener(lis, 'click', YAHOO.widget.Editor._changeColor, YAHOO.widget.Editor, true);
            } else {
                YAHOO.util.Event.removeListener(lis, 'click', YAHOO.widget.Editor._changeColor);
            }
        }
        YAHOO.util.Dom.setStyle(tar, 'display', ((state == 'block') ? 'none' : 'block'));
        if (ev) {
            YAHOO.util.Event.stopEvent(ev);
        }
    },
    _createToolbar: function() {
        tbar = [ YAHOO.util.Dom.create('div', { style : 'clear: both'}),
            YAHOO.util.Dom.create('div',
            { id: 'toolbar_1' },
            [
                YAHOO.util.Dom.create('div', { style : 'clear: both'}),
                YAHOO.util.Dom.create('a', {id: 'toolbar_bold', href: '#', title: 'Bold', className: 'yui_button'}),
                YAHOO.util.Dom.create('a', {id: 'toolbar_italic', href: '#', title: 'Italic', className: 'yui_button'}),
                YAHOO.util.Dom.create('a', {id: 'toolbar_underline', href: '#', title: 'Underline', className: 'yui_button'}),
                YAHOO.util.Dom.create('span', { className: 'yui_spacer'}),
                YAHOO.util.Dom.create('a', {id: 'toolbar_anchor', href: '#', title: 'Anchor', className: 'yui_button_disable'}),
                YAHOO.util.Dom.create('a', {id: 'toolbar_unlink', href: '#', title: 'Unlink', className: 'yui_button_disable'}),
                YAHOO.util.Dom.create('span', { className: 'yui_spacer'}),
                YAHOO.util.Dom.create('a', {id: 'toolbar_ul', href: '#', title: 'Unordered List', className: 'yui_button'}),
                YAHOO.util.Dom.create('a', {id: 'toolbar_ol', href: '#', title: 'Ordered List', className: 'yui_button'}),
                YAHOO.util.Dom.create('span', { className: 'yui_spacer'}),
                YAHOO.util.Dom.create('a', {id: 'toolbar_indent', href: '#', title: 'Indent', className: 'yui_button'}),
                YAHOO.util.Dom.create('a', {id: 'toolbar_outdent', href: '#', title: 'Outdent', className: 'yui_button'}),
                YAHOO.util.Dom.create('span', { className: 'yui_spacer'}),
                YAHOO.util.Dom.create('a', {id: 'toolbar_backcolor', href: '#', title: 'Background Color', className: 'yui_button_disable'},
                    [YAHOO.util.Dom.create('ul', {id: 'menu_backcolor', className: 'toolbar_drop', style: 'display: none'},
                        function() {
                            var _arr_colors = [];
                            for (var i = 0; i < YAHOO.widget.Editor.config.colors.length; i++) {
                                _arr_colors[_arr_colors.length] = YAHOO.util.Dom.create('li', {className: 'color_' + YAHOO.widget.Editor.config.colors[i], style: 'background-color: #' + YAHOO.widget.Editor.config.colors[i]});
                            }
                            return _arr_colors;
                        }()
                    )]
                ),

                YAHOO.util.Dom.create('div', { style : 'clear: both'})
            ]
        ),
            YAHOO.util.Dom.create('div', { style : 'clear: both'})
        ];
        //Need to add addListernet to YAHOO.util.Dom.create();
        return tbar;
    },
    _getSelection: function() {
        if (this._doc().selection) {
			return this._doc().selection;
        }
		return this._window().getSelection();
    },
    save: function() {
        this.config.editor.value = this._doc().body.innerHTML;
        this.config.editor.style.display = 'block';
    },
    clearDoc: function() {
        this._doc().body.innerHTML = '';
    },
    _execCommand: function(ev, action, value) {
        if (ev) {
            var tar = YAHOO.util.Event.getTarget(ev);
            var action = tar.id.replace('toolbar_', '');
            YAHOO.util.Dom.replaceClass(tar.id, 'yui_button', 'yui_button_sel');
        }
        if (!value) {
            var value = this._getSelection();
        }

		try {this._doc().execCommand('styleWithCSS', false, true);} catch (ex) {}
        switch (action) {
            case 'save':
                this.save();
                action = false;
                break;
            case 'anchor':
                action = 'createlink';
                value = prompt('Please enter a URL: ', 'http://');
                if (!value) {
                    action = false;
                } else {
			try {this._doc().execCommand('removeformat',false,null);} catch (ex) {}
			try {this._doc().execCommand('unlink',false,null);} catch (ex) {}
		}
                //return false;
                break;
            case 'backcolor':
                action = 'hilitecolor';
                //value = prompt('Please enter a color (hex or text): ', '');
                if (!value) {
                    action = false;
                }
                break;
            case 'ol':
                action = 'insertorderedlist';
                break;
            case 'ul':
                action = 'insertunorderedlist';
                break;
            case 'b':
            case 'i':
            case 'u':
	    case 'bold':
	    case 'italic':
	    case 'underline':
		try {this._doc().execCommand('removeformat',false,null);} catch (ex) {}
		try {this._doc().execCommand('unlink',false,null);} catch (ex) {}
		try {this._doc().execCommand('styleWithCSS', false, false);} catch (ex) {}
                break;
        }
        if (action) {
            this._doc().execCommand(action, false, value);
        }
        this._window().focus();
        
        if (ev) {
            //Stop Click Event
            YAHOO.util.Event.stopEvent(ev);
        }
    },
    _createControls: function() {
        this.config.wrapper = YAHOO.util.Dom.create('div', { id: 'yuiEditor_wrapper'});
        this.config.editor.style.display = 'none';
        this.config.editor.parentNode.replaceChild(this.config.wrapper, this.config.editor);
        this.config.wrapper.appendChild(this.config.editor);
        _tmp = YAHOO.util.Dom.create('div',
                [
                YAHOO.util.Dom.create('div',
                    {
                        id: 'yuiEditor_toolbar'
                    },
                    this._createToolbar()
                ),
                this._createIframe()
                ]
            );
        this.config.wrapper.appendChild(_tmp);
        this.config.toolbar = YAHOO.util.Dom.get('yuiEditor_toolbar');
    },
    _setup: function() {
        YAHOO.widget.Editor._doc().designMode = "on";
        YAHOO.widget.Editor._assignListeners();
        YAHOO.widget.Editor._setContent(YAHOO.widget.Editor.config.preText);
        //YAHOO.widget.Editor._setStyles();
    },
    _setStyles: function() {
        this._doc().body.style.padding = '4px';
        this._doc().body.style.fontFamily = 'Verdana';
        this._doc().body.style.fontSize = '12px';
        hideWait();
    },
    _setContent: function(str) {
        if ((typeof YAHOO.widget.Editor._doc() == 'object') && YAHOO.widget.Editor._doc().body) {
            if (!str) {
                str = YAHOO.widget.Editor.config.preText;
            }
            //var _tmp = YAHOO.widget.Editor._doc().createTextNode(str);
            //YAHOO.widget.Editor._doc().body.appendChild(_tmp);
            YAHOO.widget.Editor._doc().body.innerHTML = str;
            YAHOO.widget.Editor._setStyles();
            if (YAHOO.widget.Editor.config._timerContent) {
                clearTimeout(YAHOO.widget.Editor.config._timerContent);
            }
        } else {
            this.config._timerContent = setTimeout(YAHOO.widget.Editor._setContent, 500);
        }
    },
    _doc: function() {
        return this.config.ifrm.contentWindow.document;
    },
    _window: function() {
        return this.config.ifrm.contentWindow;
    },
    _createIframe: function() {
        ifrm = YAHOO.util.Dom.create('iframe', {
            id:'yuiEditor',
            border: '0',
            frameborder: '0',
            marginwidth: '0',
            marginheight: '0',
            leftmargin: '0',
            topmargin: '0',
            allowtransparency: '0',
            height: '250',
            width: '98%',
            src: this.config.blank_uri,
            style: 'border: 1px solid black'
            }
        );
        this.config.ifrm = ifrm;
        return ifrm;
    }
}




function showWait() {
	waitPanel = new YAHOO.widget.Panel("wait", { width: "240px", fixedcenter: true, underlay: "shadow", iframe: true, close: false, draggable: false,  modal: true, effect: {effect:YAHOO.widget.ContainerEffect.FADE, duration:0.5} });
	waitPanel.setHeader("Loading, please wait...");
	waitPanel.setBody("<img src=\"http://us.i1.yimg.com/us.yimg.com/i/us/per/gr/gp/rel_interstitial_loading.gif\"/>");   
	waitPanel.render(YAHOO.util.Dom.get('yuiEditor_wrapper'));
    waitPanel.showMaskEvent.subscribe(fixMask, waitPanel, true);
}

function hideWait() {
    waitPanel.hide();
}

YAHOO.util.Event.onAvailable('yuiEditor_wrapper', showWait);

function fixMask() {
	if (this.mask) {
        var cover = YAHOO.util.Dom.get('yuiEditor_wrapper');
        var xy = YAHOO.util.Dom.getXY(cover);
        this.mask.style.height = YAHOO.util.Dom.getStyle(cover, 'height');
        this.mask.style.width = YAHOO.util.Dom.getStyle(cover, 'width');
        YAHOO.util.Dom.setXY(this.mask, xy);
	}
}

YAHOO.widget.Overlay.prototype.center = function() {
	var scrollX = 0;
	var scrollY = 0;
    var cover = YAHOO.util.Dom.get('yuiEditor_wrapper');
    var coverXY = YAHOO.util.Dom.getXY(cover);

	var viewPortWidth = parseInt(YAHOO.util.Dom.getStyle(cover, 'width'));
	var viewPortHeight = parseInt(YAHOO.util.Dom.getStyle(cover, 'height'));
    if (isNaN(viewPortHeight)) {
        viewPortHeight = 315;
    }

	var elementWidth = this.element.offsetWidth;
	var elementHeight = this.element.offsetHeight;

	var x = ((viewPortWidth / 2) - (parseInt(elementWidth) / 2) + scrollX) + coverXY[1];
	var y = ((viewPortHeight / 2) - (parseInt(elementHeight) / 2) + scrollY) + coverXY[0];
    
	this.element.style.left = (parseInt(x) + "px");
	this.element.style.top = (parseInt(y) + "px");
	this.syncPosition();
	this.cfg.refireEvent("iframe");
};


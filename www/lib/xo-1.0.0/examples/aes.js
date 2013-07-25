/* aes.js */

var b64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';

function encodeBase64(str) {  // http://tools.ietf.org/html/rfc4648
   var o1, o2, o3, h1, h2, h3, h4, bits, i=0, enc='';
   
   str = encodeUTF8(str);  // encode multi-byte chars into UTF-8 for byte-array

   do {  // pack three octets into four hexets
      o1 = str.charCodeAt(i++);
      o2 = str.charCodeAt(i++);
      o3 = str.charCodeAt(i++);
      
      bits = o1<<16 | o2<<8 | o3;
      
      h1 = bits>>18 & 0x3f;
      h2 = bits>>12 & 0x3f;
      h3 = bits>>6 & 0x3f;
      h4 = bits & 0x3f;
      
      // end of string? index to '=' in b64
      if (isNaN(o3)) h4 = 64;
      if (isNaN(o2)) h3 = 64;
      
      // use hexets to index into b64, and append result to encoded string
      enc += b64.charAt(h1) + b64.charAt(h2) + b64.charAt(h3) + b64.charAt(h4);
   } while (i < str.length);
   
   return enc;
}

function decodeBase64(str) {
   var o1, o2, o3, h1, h2, h3, h4, bits, i=0, enc='';

   do {  // unpack four hexets into three octets using index points in b64
      h1 = b64.indexOf(str.charAt(i++));
      h2 = b64.indexOf(str.charAt(i++));
      h3 = b64.indexOf(str.charAt(i++));
      h4 = b64.indexOf(str.charAt(i++));
      
      bits = h1<<18 | h2<<12 | h3<<6 | h4;
      
      o1 = bits>>16 & 0xff;
      o2 = bits>>8 & 0xff;
      o3 = bits & 0xff;
      
      if (h3 == 64)      enc += String.fromCharCode(o1);
      else if (h4 == 64) enc += String.fromCharCode(o1, o2);
      else               enc += String.fromCharCode(o1, o2, o3);
   } while (i < str.length);

   return decodeUTF8(enc);  // decode UTF-8 byte-array back to Unicode
}

function encodeUTF8(str) {  // encode multi-byte string into utf-8 multiple single-byte characters 
  str = str.replace(
      /[\u0080-\u07ff]/g,  // U+0080 - U+07FF = 2-byte chars
      function(c) { 
        var cc = c.charCodeAt(0);
        return String.fromCharCode(0xc0 | cc>>6, 0x80 | cc&0x3f); }
    );
  str = str.replace(
      /[\u0800-\uffff]/g,  // U+0800 - U+FFFF = 3-byte chars
      function(c) { 
        var cc = c.charCodeAt(0); 
        return String.fromCharCode(0xe0 | cc>>12, 0x80 | cc>>6&0x3F, 0x80 | cc&0x3f); }
    );
  return str;
}

function decodeUTF8(str) {  // decode utf-8 encoded string back into multi-byte characters
  str = str.replace(
      /[\u00c0-\u00df][\u0080-\u00bf]/g,                 // 2-byte chars
      function(c) { 
        var cc = (c.charCodeAt(0)&0x1f)<<6 | c.charCodeAt(1)&0x3f;
        return String.fromCharCode(cc); }
    );
  str = str.replace(
      /[\u00e0-\u00ef][\u0080-\u00bf][\u0080-\u00bf]/g,  // 3-byte chars
      function(c) { 
        var cc = (c.charCodeAt(0)&0x0f)<<12 | (c.charCodeAt(1)&0x3f<<6) | c.charCodeAt(2)&0x3f; 
        return String.fromCharCode(cc); }
    );
  return str;
}


function byteArrayToHexStr(b) {  // convert byte array to hex string for displaying test vectors
  var s = '';
  for (var i=0; i<b.length; i++) s += b[i].toString(16) + ' ';
  return s;
}

Ext.onReady(function(){

    Ext.QuickTips.init();

    // turn on validation errors beside the field globally
    Ext.form.Field.prototype.msgTarget = 'under';

    /*
     * ================  Simple form  =======================
     */
    var simple = new Ext.FormPanel({
        labelWidth: 125, // label settings here cascade unless overridden
        labelAlign: 'right',
        url:'JavaScript://',
        frame:true,
        title: 'Test Script',
        bodyStyle:'padding:5px 5px 0',
        width: 600,
        defaults: {width: 440},
        defaultType: 'textfield',

        items: [{
                fieldLabel: 'Password',
                name: 'password',
                id: 'f-password',
                value: 'L0ck it up saf3',
                allowBlank: true
            },{
                fieldLabel: 'Plaintext',
                xtype: 'textarea',
                name: 'plaintext',
                id: 'f-plaintext',
                value: 'pssst ... đon\'t tell anyøne!',
                allowBlank: false,
                grow: true,
                growMin: 30,
                preventScrollbars: true
            },{
                fieldLabel: 'Encrypted Text',
                xtype: 'textarea',
                name: 'ciphertext',
                id: 'f-ciphertext',
                readOnly: true,
                grow: true,
                growMin: 30,
                preventScrollbars: true
            },{
                fieldLabel: 'Decrypted Text',
                xtype: 'textarea',
                name: 'plaintext2',
                id: 'f-plaintext-2',
                readOnly: true,
                grow: true,
                growMin: 30,
                preventScrollbars: true
            }
        ],

        buttons: [{
            text: 'Encrypt'
          , handler: function () {
                var form = simple.getForm();
                var password = form.findField('f-password').getValue();
                var plaintext = form.findField('f-plaintext').getValue();
                form.findField('f-ciphertext').setValue(Ext.ux.Crypto.AES.encrypt(plaintext, password, 256));
            }
        },{
            text: 'Decrypt'
          , handler: function () {
                var form = simple.getForm();
                var password = form.findField('f-password').getValue();
                var ciphertext = form.findField('f-ciphertext').getValue();
                form.findField('f-plaintext-2').setValue(Ext.ux.Crypto.AES.decrypt(ciphertext, password, 256));
            }
        },{
            text: 'Clear'
          , handler: function () {
                var form = simple.getForm();
                form.findField('f-ciphertext').reset();
                form.findField('f-plaintext-2').reset();
            }
        }]
    });

    simple.render('simple');

    var test = new Ext.FormPanel({
        labelWidth: 125, // label settings here cascade unless overridden
        labelAlign: 'right',
        url:'JavaScript://',
        frame:true,
        title: 'Test Script',
        bodyStyle:'padding:5px 5px 0',
        width: 600,
        defaults: {width: 440},
        defaultType: 'textfield',

        items: [{
            fieldLabel: '128-bit Test Vector',
            value: '69 c4 e0 d8 6a 7b 04 30 d8 cd b7 80 70 b4 c5 5a',
            readOnly: true
        },{
            fieldLabel: '192-bit Test Vector',
            value: 'dd a9 7c a4 86 4c df e0 6e af 70 a0 ec 0d 71 91',
            readOnly: true
        },{
            fieldLabel: '256-bit Test Vector',
            value: '8e a2 b7 ca 51 67 45 bf ea fc 49 90 4b 49 60 89',
            readOnly: true
        }],

        buttons: [{
            text: '128-bit Test Vector',
            handler: function() {
                Ext.MessageBox.alert('Result', byteArrayToHexStr(Ext.ux.Crypto.AES.cipher([0x00,0x11,0x22,0x33,0x44,0x55,0x66,0x77,0x88,0x99,0xaa,0xbb,0xcc,0xdd,0xee,0xff],          Ext.ux.Crypto.AES.keyExpansion([0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f]))));
            }
        },{
            text: '192-bit Test Vector',
            handler: function() {
                Ext.MessageBox.alert('Result', byteArrayToHexStr(Ext.ux.Crypto.AES.cipher([0x00,0x11,0x22,0x33,0x44,0x55,0x66,0x77,0x88,0x99,0xaa,0xbb,0xcc,0xdd,0xee,0xff],          Ext.ux.Crypto.AES.keyExpansion([0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f, 0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17]))));
            }
        },{
            text: '256-bit Test Vector',
            handler: function() {
                Ext.MessageBox.alert('Result', byteArrayToHexStr(Ext.ux.Crypto.AES.cipher([0x00,0x11,0x22,0x33,0x44,0x55,0x66,0x77,0x88,0x99,0xaa,0xbb,0xcc,0xdd,0xee,0xff],          Ext.ux.Crypto.AES.keyExpansion([0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f, 0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f]))));
            }
        }]
    });
    test.render('test');
});

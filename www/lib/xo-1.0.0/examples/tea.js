/* tea.js */

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
                value: 'encryption-pw',
                allowBlank:true
            },{
                fieldLabel: 'Plaintext',
                xtype: 'textarea',
                name: 'plaintext',
                id: 'f-plaintext',
                value: 'some highly secret text to be encrypted',
                allowBlank:false,
                grow: true,
                growMin:30,
                preventScrollbars:true
            },{
                fieldLabel: 'Encrypted Text',
                xtype: 'textarea',
                name: 'ciphertext',
                id: 'f-ciphertext',
                readOnly: true,
                grow: true,
                growMin:30,
                preventScrollbars:true
            },{
                fieldLabel: 'Decrypted Text',
                xtype: 'textarea',
                name: 'plaintext2',
                id: 'f-plaintext-2',
                readOnly: true,
                grow: true,
                growMin:30,
                preventScrollbars:true
            }
        ],

        buttons: [{
            text: 'Encrypt'
          , handler: function () {
                var form = simple.getForm();
                var password = form.findField('f-password').getValue();
                var plaintext = form.findField('f-plaintext').getValue();
                form.findField('f-ciphertext').setValue(Ext.ux.Crypto.TEA.encrypt(plaintext, password, 256));
            }
        },{
            text: 'Decrypt'
          , handler: function () {
                var form = simple.getForm();
                var password = form.findField('f-password').getValue();
                var ciphertext = form.findField('f-ciphertext').getValue();
                form.findField('f-plaintext-2').setValue(Ext.ux.Crypto.TEA.decrypt(ciphertext, password, 256));
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
});

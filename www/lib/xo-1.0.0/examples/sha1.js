/* sha1.js */

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
        title: 'Enter any message to check its SHA-1 hash:',
        bodyStyle:'padding:5px 5px 0',
        width: 600,
        defaults: {width: 440},
        defaultType: 'textfield',

        items: [{
                fieldLabel: 'Message',
                xtype: 'textarea',
                name: 'message',
                id: 'f-message',
                value: 'abc',
                allowBlank:false,
                grow: true,
                growMin:30,
                preventScrollbars:true
            },{
                fieldLabel: 'Hash',
                xtype: 'textarea',
                name: 'hashtext',
                id: 'f-hashtext',
                readOnly: true,
                grow: true,
                growMin:30,
                preventScrollbars:true
            }
        ],

        buttons: [{
            text: 'Generate Hash'
          , handler: function () {
                var form = simple.getForm();
                var message = form.findField('f-message').getValue();
                form.findField('f-hashtext').setValue(Ext.ux.Crypto.SHA1.hash(message));
            }
        },{
            text: 'Clear'
          , handler: function () {
                var form = simple.getForm();
                form.findField('f-hashtext').reset();
            }
        }]
    });

    simple.render('simple');
});

Ext.ux.grid.livegrid.JsonStore = function(c){
    Ext.ux.grid.livegrid.JsonStore.superclass.constructor.call(this, Ext.apply(c, {
        proxy: c.proxy || (!c.data ? new Ext.data.HttpProxy({url: c.url}) : undefined),
        reader: new Ext.ux.grid.livegrid.JsonReader(c, c.fields)
    }));
};
Ext.extend(Ext.ux.grid.livegrid.JsonStore, Ext.ux.grid.livegrid.Store);
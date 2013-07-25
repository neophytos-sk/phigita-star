/**
 * Ext.ux.grid.livegrid.GridPanel
 * Copyright (c) 2007-2008, http://www.siteartwork.de
 *
 * Ext.ux.grid.livegrid.GridPanel is licensed under the terms of the
 *                  GNU Open Source GPL 3.0
 * license.
 *
 * Commercial use is prohibited. Visit <http://www.siteartwork.de/livegrid>
 * if you need to obtain a commercial license.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/gpl.html>.
 *
 */

Ext.namespace('Ext.ux.grid.livegrid');

/**
 * @class Ext.ux.grid.livegrid.GridPanel
 * @extends Ext.grid.GridPanel
 * @constructor
 * @param {Object} config
 *
 * @author Thorsten Suckow-Homberg <ts@siteartwork.de>
 */
Ext.ux.grid.livegrid.GridPanel = Ext.extend(Ext.grid.GridPanel, {

	totalProperty: 'totalCount',
    /**
     * Overriden since the original implementation checks for
     * getCount() of the store, not getTotalCount().
     *
     */
    walkCells : function(row, col, step, fn, scope)
    {
        var ds  = this.store;
        var _oF = ds.getCount;

        ds.getCount = ds.getTotalCount;

        var ret = Ext.ux.grid.livegrid.GridPanel.superclass.walkCells.call(this, row, col, step, fn, scope);

        ds.getCount = _oF;

        return ret;
    }

});
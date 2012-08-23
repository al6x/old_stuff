//
// AJAX Table helpers
//
Rad.Table = new Class({
  initialize: function(tableQ){    
    this.table = tableQ.toElement(true);
    if(!this.table) throw("no table '" + tableQ + "'!");
    this.tbody = this.table.getChild('tbody');
  },
  anew: function(form){rad.dialog().show(form);},  
  create: function(lineQ){lineQ.toElement(true).inject(this.tbody);},
  edit: function(form){rad.dialog().show(form);},
  line: function(lineQ){return new Rad.Table.Line(this, lineQ);}
});

Rad.Table.Line = new Class({
  initialize: function(table, lineQ){
    this.table = table;
    this.tr = table.tbody.getChild(lineQ);
    if(!this.tr) throw("no table row with '" + lineQ + "'!");
  },
  destroy: function(){this.tr.destroy();},
  update: function(line){line.toElement(true).replaces(this.tr);}
});
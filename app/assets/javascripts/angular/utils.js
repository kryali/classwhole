angular.module('utils', []).service('ColorList', ColorList);

function ColorList() {
  this.nextColor = 0;
  this.available = [];
  this.assigned = {};
}

ColorList.prototype.get = function(id) {
  var colorIndex = this.assigned[id];
  if ( colorIndex == null) {
    if (this.available.length > 0 ) {
      colorIndex = this.available[0];
      this.available = this.available.splice(1, this.available.length);
    } else {
      colorIndex = this.nextColor;
      this.nextColor += 1;
    }
    this.assigned[id] = colorIndex;
  }
  return colorIndex;
}

ColorList.prototype.remove = function(id) {
  var colorIndex = this.assigned[id];
  if (colorIndex == null) {
    throw new Error("Tried to remove an assigned object");
  }

  this.available.push(colorIndex);
  this.assigned[id] = null;
}

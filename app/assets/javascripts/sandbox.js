dragging = false;

function handleDragStart(event) {
  
  var className = event.srcElement.className;
  var baby;
  if( className.indexOf("white") != -1 )
    baby ="white";
  else
    baby = "black";

  dragging = true;
  event.dropEffect = "move";
  event.effectAllowed = "move";
  event.dataTransfer.setData("text/html", baby);
}

function dragEnd(event) {
  dragging = false;
  //console.log( event );
}

function dragOver(event) {
  if( event.preventDefault ) {
    event.preventDefault(); // tutorial set it was neccessary? what the fuck?
  }
  event.dataTransfer.dropEffect = "move";
}

function dragEnter(event) {
  //console.log( event );
  $(event.currentTarget).removeClass("vagina").addClass("megusta");
}

function dragLeave(event) {
  $(event.currentTarget).removeClass("megusta").addClass("vagina");
}

function drop(event) {
  // Idk why i have to do this
  event.stopPropagation();
  event.preventDefault();

  if(event.dataTransfer.getData("text/html") == "white")
    $(event.currentTarget).removeClass("megusta").addClass("white-baby");
  else
    $(event.currentTarget).removeClass("megusta").addClass("black-baby");

  setTimeout( function() {
    if( !dragging ) 
      $(".target").removeClass("black-baby").removeClass("white-baby").addClass("vagina");
  }, 3400);

  return false;
}

$(document).ready( function() {
  $(".penis").bind("dragend", dragEnd);
  $(".penis").each( function() {
    $(this)[0].addEventListener("dragstart", handleDragStart, false );
  });

  // Should use addEventListener instead of bind because it passes a different event to the function
  $(".target")[0].addEventListener("dragover", dragOver, false );
  $(".target")[0].addEventListener("drop", drop, false );

  $(".target").bind("dragenter", dragEnter );
  $(".target").bind("dragleave", dragLeave );
  //$(".target").bind("dragover", dragOver );

});

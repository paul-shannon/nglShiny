HTMLWidgets.widget({

  name: 'nglShiny',
  type: 'output',

  factory: function(el, width, height) {
    console.log("manufacturing nglShiny widget");
    return {
       renderValue: function(x) {
          var stage;
          stage = new NGL.Stage(el);
          window.stage = stage;
          stage.loadFile("rcsb://1pcr", {defaultRepresentation: true});
          },
       resize: function(width, height) {
          console.log("entering resize");
           correctedHeight = window.innerHeight * 0.9;
          $("#nglShiny").height(correctedHeight);
          console.log("nglShiny.resize: " + width + ", " + correctedHeight + ": " + height);
          stage.handleResize()
          }
    } // return
  } // factory
});  // widget

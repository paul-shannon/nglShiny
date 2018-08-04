HTMLWidgets.widget({

  name: 'nglShiny',
  type: 'output',

  factory: function(el, width, height) {
    console.log("manufacturing nglShiny widget");
    return {
       renderValue: function(options) {
          console.log("---- options");
          console.log(options)
          var stage;
          stage = new NGL.Stage(el);
          window.stage = stage;
          uri = "rcsb://" + options.pdbID;
          stage.loadFile(uri, {defaultRepresentation: true});
          //stage.loadFile("rcsb://1pcr", {defaultRepresentation: true});
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

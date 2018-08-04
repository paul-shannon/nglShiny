HTMLWidgets.widget({

  name: 'nglShiny',
  type: 'output',

  factory: function(el, width, height) {
    return {
      renderValue: function(x) {
        var stage;
        stage = new NGL.Stage(el);
        stage.loadFile("rcsb://1crn.mmtf", {defaultRepresentation: true});
      },
    resize: function(width, height) {
        // TODO: code to re-render the widget with a new size
       }
    } // return
  } // factory
});  // widget

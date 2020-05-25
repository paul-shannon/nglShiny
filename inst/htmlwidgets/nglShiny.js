// shameful use of primitive global variables for now
// widget tips https://deanattali.com/blog/htmlwidgets-tips/
window.pdbID = "1crn";
window.representation = "cartoon";
window.colorScheme = "residueIndex";
//------------------------------------------------------------------------------------------------------------------------
HTMLWidgets.widget({

  name: 'nglShiny',
  type: 'output',
      

  factory: function(el, width, height) {
    var stage;
    var pdbID = el.pdbID;
    var htmlContainer = el.htmlContainer;
    console.log("manufacturing nglShiny widget,  el: " + el + " width: " + width + "  height: " + height)
    //console.log("manufacturing nglShiny widget for " + pdbID + " in " + htmlContainer);

    Shiny.addCustomMessageHandler("fit", function(message){
        var htmlContainer = message.htmlContainer;
        console.log("in factory, nglShiny fit")
        console.log(message)
        console.log("pdbID: " + pdbID)
        console.log("htmlContainer: " + htmlContainer);
        var stage = document.getElementById(htmlContainer).stage;
        console.log("stage: " + stage)
        stage.autoView()
        })

    return {
       renderValue: function(options) {
          console.log("---- options");
          console.log(options);
          pdbID = options.pdbID;
          htmlContainer = options.htmlContainer;
          var stage = new NGL.Stage(htmlContainer, {backgroundColor:'beige'});
          document.getElementById(htmlContainer).stage = stage;
          uri = "rcsb://" + pdbID;
          stage.loadFile(uri, {defaultRepresentation: false}).then(function(o){
	      o.autoView()
              var namedComponentsProvided = Object.keys(options).indexOf("namedComponents") >= 0;
              if(!namedComponentsProvided){
                 console.log("--- no namedComponentsProvided, using cartoon + residueIndex")
                 o.addRepresentation("cartoon", {sele: "all", colorScheme: "residueIndex"});
                 }
              else{
                  var namedComponents = options.namedComponents;
                  var componentNames = Object.keys(namedComponents);
                  console.log("--- componentNames");
                  console.log(componentNames);
		  for (i=0; i < componentNames.length; i++){ 
                     var name = componentNames[i];
                     console.log("==== adding rep for " + name);
                     component = namedComponents[name];
                     var rep = component.representation;
		     var selection = component.selection;
		     var colorScheme = component.colorScheme;
                     console.log("rep: " + rep);
                     console.log("selection: " + selection);
                     console.log("name: " + name);
                     console.log("colorScheme: " + colorScheme);
                     o.addRepresentation(rep, {
                        sele: selection,
			name: name,
                        colorScheme: colorScheme,
			visible: component.visible
                        })
                     } // for i
                  } // if options.namedComponents
              }) // then 
          },
       resize: function(width, height){
          console.log("entering resize of htmlContainer: " + htmlContainer);
          correctedHeight = window.innerHeight * 0.9;
          // $("#nglShiny").height(correctedHeight);
          $(htmlContainer).height(correctedHeight);
          console.log("nglShiny.resize: " + width + ", " + correctedHeight + ": " + height);
          var stage = document.getElementById(htmlContainer).stage;
          stage.handleResize()
          }, 

        fit: function(){
           console.log("fit " + pdbID);
           },

    } // return
  } // factory
});  // widget
//------------------------------------------------------------------------------------------------------------------------
function setComponentNames(x, namedComponents)
{
   console.log("--- setComponentNames");
   console.log(namedComponents);

    // stage.getComponentsByName(window.pdbID).list[0].removeAllRepresentations()

   for(name in namedComponents){
     attributes = namedComponents[name];
     var rep = attributes.representation;
     var selectionString = attributes.selection;
     console.log("name '" + name + "' for '" + selectionString + "' rep: " + rep)
     debugger;
     //stage.getComponentsByName(window.pdbID).addRepresentation(rep, {sele: selectionString,
     //								     name: name})
     } // for name
   
   //component.addRepresentation('ball+stick', {name: 'ligand', sele: 'ligand'})
   //stage.getComponentsByName(window.pdbID).addRepresentation(rep, attributes);

} // setComponentNames
//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("fit", function(message){

    console.log("nglShiny fit")
    console.log(message)
    stage.autoView()
    })

//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("removeAllRepresentations", function(message){

   if(typeof(stage) != "undefined")
      stage.getComponentsByName(window.pdbID).list[0].removeAllRepresentations()
    })

//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("setRepresentation", function(message){

    var rep = message;
    console.log("nglShiny setRepresentation: " + rep)
    window.representation = rep;
    stage.getComponentsByName(window.pdbID).addRepresentation(rep)
    })

//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("setColorScheme", function(message){

    console.log("nglShiny setColorScheme")
    var newScheme = message[0];
    window.colorScheme = newScheme;
    console.log("new color scheme: " + newScheme);
    // debugger;
    stage.getComponentsByName(window.pdbID).addRepresentation(window.representation, {colorScheme: newScheme})
    })

//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("setPDB", function(message){

   //debugger;

   if(typeof(stage) != "undefined")
      stage.removeAllComponents()

    var uri = message.uri;
    console.log(" about to loadFile: " + uri);
    stage.loadFile(uri, {ext: "pdb", defaultRepresentation: true}).then(function(o){
        o.autoView()
        stage.autoView()
        })
    //stage.loadFile(uri).then(function(comp){
    //  comp.addRepresentation("cartoon", {colorScheme: "residueIndex"});
    //  })
    //stage.getComponentsByName(window.pdbID).addRepresentation(window.representation, {colorScheme: window.colorScheme})
    //stage.autoView()
    })

if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("setLocalPDB", function(message){
    // Add PBDs from local sources, convert pdb file into a single long string in R and send it as message
    if(typeof(stage) != "undefined")
       stage.removeAllComponents()

    var uri = message[0] // Noticed that the structure is changed but will otherwise keep it with what I know works
    var stringBlob = new Blob( [ uri ], { type: 'text/plain'} );
    console.log("nglShiny setPDB:");
    stage.loadFile(stringBlob, {ext: "pdb", defaultRepresentation: true}).then(function (o) {
      o.auto.View()
    });
});

//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("select", function(message){

    residueString = message[0];
    console.log("nglShiny select: " + residueString)
    stage.getComponentsByName(window.pdbID).addRepresentation("ball+stick", {sele: residueString})
    //stage.getComponentsByName(window.pdbID).addRepresentation("ball+stick", {sele: "23, 24, 25, 26, 27, 28, 29, 30"})
    })

//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("showSelection", function(message){

    //residueString = message[0];
    var rep = message.representation;
    var selection = message.selection;
    var colorScheme = message.colorScheme;
    var name = message.name;
    var attributes = {sele: selection, colorScheme: colorScheme, name: name};
    console.log("attributes")
    console.log(attributes)
    console.log("nglShiny showSelection: " + rep + ",  " + selection);
    //stage.getComponentsByName(window.pdbID).addRepresentation(rep, {sele: selection, colorScheme: colorScheme, name: name})
    stage.getComponentsByName(window.pdbID).addRepresentation(rep, attributes);
    // stage.getComponentsByName('1ztu').addRepresentation('ball+stick', {sele: 'not helix and not sheet and not turn and not water'})
    })

//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("setVisibility", function(message){

    var repName = message.representationName;
    var newState = message.newState;
    console.log("set visibility " + repName + "  " + newState)
    stage.getRepresentationsByName(repName).setVisibility(newState)
    })

//------------------------------------------------------------------------------------------------------------------------

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
    var pdbID = el.pdbID;
    window.pdbID = el.pdbID;
    var htmlContainer = el.htmlContainer;
    console.log("manufacturing nglShiny widget,  el: " + el + " width: " + width + "  height: " + height)
    //console.log("manufacturing nglShiny widget for " + pdbID + " in " + htmlContainer);

       // see Automatic View, default focused on all representation, selection string
       // to center a specific component.
    Shiny.addCustomMessageHandler("fit", function(message){
        //var htmlContainer = message.htmlContainer;
        console.log("in factory, nglShiny fit")
        console.log(message)
        console.log("pdbID: " + pdbID)
        //console.log("htmlContainer: " + htmlContainer);
        //stage = document.getElementById(htmlContainer).stage;
        console.log("stage: " + stage)
        stage.autoView()
        })

    return {
       renderValue: function(options) {
          console.log("---- options");
          console.log(options);
          pdbID = options.pdbID;
          htmlContainer = options.htmlContainer;
          stage = new NGL.Stage(htmlContainer, {backgroundColor:'beige'});
          document.getElementById(htmlContainer).stage = stage;
          uri = "rcsb://" + pdbID;
          if(pdbID.startsWith("http"))
             uri = pdbID
          console.log(" pdbID: " + pdbID)
          console.log("   uri: " + uri)
          stage.loadFile(uri, {defaultRepresentation: false}).then(function(o){
              var namedComponentsProvided = Object.keys(options).indexOf("namedComponents") >= 0;
              o.autoView()
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
                     var componentName = componentNames[i];
                     component = namedComponents[componentName];
                     var givenName = component.name;
                     console.log("==== adding rep for " + givenName);
                     var rep = component.representation;
		     var selection = component.selection;
		     var colorScheme = component.colorScheme;
                     console.log("rep: " + rep);
                     console.log("selection: " + selection);
                     console.log("givenName: " + givenName);
                     console.log("colorScheme: " + colorScheme);
                     var newRep = o.addRepresentation(rep, {
                        sele: selection,
			name: givenName,
                        colorScheme: colorScheme,
			visible: component.visible
                        })
                      console.log("status of addRepresentation(" + givenName + "): " +
                                  newRep.repr.dataList.length);
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
//if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("fit", function(message){
//
//    console.log("nglShiny fit")
//    console.log(message)
//    stage.autoView()
//    })
//
//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("spin", function(message){

    if(typeof(stage) != "undefined"){
       var newState = message.newState;
       console.log("--- spin " + newState)
       stage.setSpin(newState);
       }
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

   console.log("--- setPDB");
   console.log(message);
   if(typeof(stage) != "undefined")
      stage.removeAllComponents()

    var pdbID = message.pdbID;
    var uri;
    if(pdbID.startsWith("http")){
        uri = pdbID;
    } else {
       uri = "rcsb://" + message.pdbID;
       }
   
    console.log(" about to loadFile: " + uri);
    //stage.loadFile(uri, {ext: "pdb", defaultRepresentation: true}).then(function(o){
    stage.loadFile(uri, {defaultRepresentation: false}).then(function(o){
        console.log("--- stage.loadFile then block")
        o.autoView()
        o.addRepresentation("cartoon", {sele: "all", colorScheme: "residueIndex"});
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
      o.autoView()
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

    var htmlContainer = message.htmlContainer;
    var repName = message.representationName;
    var newState = message.newState;
    console.log("set visibility " + repName + "  " + newState)
    var stage = document.getElementById(htmlContainer).stage;
    stage.getRepresentationsByName(repName).setVisibility(newState)
    })

//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("center", function(message){

    var htmlContainer = message.htmlContainer;
    var selectionString = message.selectionString;
    var stage = document.getElementById(htmlContainer).stage;
       // window.pdbID  '1S5L'
    var duration = 1;
    console.log("center " + selectionString + "  duration: " + duration);
       // todo: duration does not work (18 jun 2022)
    stage.getComponentsByName(window.pdbID).autoView(selectionString);
    })

//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("setCameraDistance", function(message){

    var htmlContainer = message.htmlContainer;
    var newDistance = message.distance
    var stage = document.getElementById(htmlContainer).stage;
    stage.viewerControls.distance(newDistance)
    })

//------------------------------------------------------------------------------------------------------------------------

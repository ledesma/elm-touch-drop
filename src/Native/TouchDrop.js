Elm.Native = Elm.Native || {};
Elm.Native.TouchDrop = {};
Elm.Native.TouchDrop.make = function(localRuntime) {
  localRuntime.Native = localRuntime.Native || {};
  localRuntime.Native.TouchDrop = localRuntime.Native.TouchDrop || {};
  if (localRuntime.Native.TouchDrop.values)
  {
    return localRuntime.Native.TouchDrop.values;
  }

  var Maybe = Elm.Maybe.make(localRuntime);
  var Json = Elm.Native.Json.make(localRuntime);
  var Signal = Elm.Native.Signal.make(localRuntime);


  function Tuple2(x, y)
  {
    return {
      ctor: '_Tuple2',
      _0: x,
      _1: y
    };
  }

  // This is taken 1:1 from https://github.com/elm-lang/core/blob/3.0.0/src/Native/Utils.js
  function getXY(e)
  {
    var posx = 0;
    var posy = 0;
    if (e.pageX || e.pageY)
    {
      posx = e.pageX;
      posy = e.pageY;
    }
    else if (e.clientX || e.clientY)
    {
      posx = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
      posy = e.clientY + document.body.scrollTop + document.documentElement.scrollTop;
    }

    if (localRuntime.isEmbed())
    {
      var rect = localRuntime.node.getBoundingClientRect();
      var relx = rect.left + document.body.scrollLeft + document.documentElement.scrollLeft;
      var rely = rect.top + document.body.scrollTop + document.documentElement.scrollTop;
      // TODO: figure out if there is a way to avoid rounding here
      posx = posx - Math.round(relx) - localRuntime.node.clientLeft;
      posy = posy - Math.round(rely) - localRuntime.node.clientTop;
    }
    return Tuple2(posx, posy);
  }


  function onTouch(name, options, decoder, createMessage)
  {
    function eventHandler(event)
    {
      if(event.touches != undefined && (options.fingers == -1 || options.fingers == event.touches.length)) {
        var value = A2(Json.runDecoderValue, decoder, event);
        if (value.ctor === 'Ok')
        {
          if (options.stopPropagation)
          {
            event.stopPropagation();
          }
          if (options.preventDefault)
          {
            event.preventDefault();
          }
          Signal.sendMessage(createMessage(value._0));
        }
      }
    }
    return property('on' + name, eventHandler);
  }

  function property(key, value)
  {
    return {
      key: key,
      value: value
    };
  }


  function dropTarget(evt) {
    var point = getXY(evt);
    var dropTarget = elementWithDropTarget(document.elementFromPoint(point._0, point._1));
    if(dropTarget == undefined) {
      return Maybe.Nothing
    }
    else {
      return Maybe.Just(dropTarget)
    }
  }

  //Recursive search for the element with droptarget
  function elementWithDropTarget(elem) {
    if(elem == undefined) {
      return undefined
    }
    dropTarget = elem.getAttribute('droptarget')
    if(dropTarget != undefined) {
      return dropTarget
    }
    return elementWithDropTarget(elem.parentElement)
  }


  function createDragShadow(evt) {
    var dragShadow = document.getElementById("dragShadow");
    if(dragShadow == null) {
      var original = evt.target
      dragShadow = original.cloneNode(true)
      dragShadow.id = "dragShadow";
      dragShadow.setAttribute("style", dragShadow.getAttribute("style")
        + "; opacity: 0.5; position: absolute; pointer-events: none");
      document.body.appendChild(dragShadow);
      moveDragShadow(evt);
    }
    return evt;
  }

  function moveDragShadow(evt) {
    var dragShadow = document.getElementById("dragShadow");
    if(dragShadow != null) {
      var xy = getXY(evt);
      dragShadow.style.left = (xy._0-(dragShadow.clientWidth/2)) +"px";
      dragShadow.style.top = (xy._1-(dragShadow.clientHeight/2)) +"px";
    }
    return evt;
  }

  function clearDragShadow(evt) {
    var dragShadow = document.getElementById("dragShadow");
    if(dragShadow != null) {
      dragShadow.parentNode.removeChild(dragShadow);
    }
    return evt;
  }


  function log(x) {
    console.log(x);
    return x;
  }


  return localRuntime.Native.TouchDrop.values = { 
    dropTarget : dropTarget, 
    getXY : getXY, 
    logIt : log,
    createDragShadow : createDragShadow,
    moveDragShadow : moveDragShadow,
    clearDragShadow : clearDragShadow,
    onTouch : F4(onTouch)
  };

};

# TRANSITIONDELEGATE
# ==========

# Transition is CSS3 Transition engine with jQuery fallback. 

"use strict"  

effects = Namespace("SEQ.effects")

class effects.TransitionDelegate
  constructor: (@element, @property, @value, @duration) ->
    # if duration, add "transitionEnd" listener
    if @duration > 0
      @element.addEventListener(effects.Transition.TransitionEndNames[effects.Transition.GetProp('Transition')], @onTransitionEnd, false)
    # add the transition CSS properties
    @addTransitionStyles()
    # add the styling CSS properties
    
    setTimeout =>
      @addStyles()
      # no duration so fire callback immediately
      if @duration is 0
        # pass empty event object in due to crazy bug in iOS
        @onTransitionEnd()
    , 10

  addStyles: =>
    if @property is "opacity" and @value is 1
      @element.style["display"] = "block"

    # if height or width and transitioning to "auto" size
    if (@property is "height" or "width") and @value is "auto"         
      size = @getClientAutoSize(@element)
      # set to actual height/width - "auto" will be added back again once transition is complete
      @element.style[@property] = "#{if @property is "height" then size.height else size.width}px"

    # if we're animating from "auto" width/height to any other value
    else if (@property is "height" or "width") and @element.style[@property] is "auto"      
      # ditch the transition styling temporarily to prevent unwanted animation
      @removeTransitionStyles()
      # set the element to it's actual width/height
      @element.style[@property] = "#{if @property is "height" then @element.clientHeight else @element.clientWidth}px" 
      # wait 15ms for DOM to update
      setTimeout =>
        # add the transition style back
        @addTransitionStyles()
        # set new value
        @element.style[@property] = "#{@value}px"
      , 50
    else
      setTimeout =>
        @element.style[@property] = "#{@value+@pxMap(@property, @value)}"
      , 10
  
  getClientAutoSize: (element) =>
    clone = element.cloneNode(true)
    body = document.querySelector("body")
    body.appendChild(clone)
    clone.style.width = "auto"
    clone.style.height = "auto"
    clone.style.visibility = "hidden"
    clone.style.display = "block"
    size =
      width: clone.clientWidth
      height: clone.clientHeight
    body.removeChild(clone)
    return size
     
  onTransitionEnd: (e) =>
    # if there was an event, remove the listener
    if e?
      e.target.removeEventListener(e.type, @onTransitionEnd, false)    
    
    # remove 
    @removeTransitionStyles()  
    
    if @property is "opacity" and @value is 0
      @element.style["display"] = "none"

    # reset to "auto" if needed  
    if @value is "auto"
      if @property is "height" or "width"
        @element.style[@property] = "auto"

  addTransitionStyles: =>
    @element.style["#{effects.Transition.GetProp('TransitionProperty')}"] = "all"  
    @element.style["#{effects.Transition.GetProp('TransitionDuration')}"] = "#{@duration / 1000}s"
    @element.style["#{effects.Transition.GetProp('TransitionTimingFunction')}"] = "ease-in-out"
    
  removeTransitionStyles: =>
    @element.style["#{effects.Transition.GetProp('TransitionProperty')}"] = ""
    @element.style["#{effects.Transition.GetProp('TransitionDuration')}"] = ""
    @element.style["#{effects.Transition.GetProp('TransitionTimingFunction')}"] = ""
  
  # utility function, returns "px" if obj in array
  pxMap: (property, value) ->
    suffix = ""

    # if value already has px
    if value.indexOf? and value.indexOf("px") > -1
      return suffix
    
    for prop in ["left", "right", "top", "bottom", "width", "height"]
      if property is prop then suffix = "px"
    
    return suffix


# TRANSITIONDELEGATE
# ==========

# Transition is CSS3 Transition engine with jQuery fallback. 

"use strict"  

effects = Namespace("SEQ.effects")

class effects.TransitionController
  constructor:(@options) ->
    @transitionEndStr = effects.Transition.TransitionEndNames[effects.Transition.GetProp('Transition')]
    @numTransitions = 0
    @numTransitionsComplete = 0
    elements = []
    
    # if jQuery object
    if @options.target instanceof jQuery       
      for element, i in @options.target
        elements.push(@options.target.get(i))           
    # if an Array    
    else if @options.target.constructor is Array
      elements = @options.target
    # otherwise target was a HTMLElement in the first place  
    else
      elements = [@options.target]
    
    @transition(elements)
  
  transition: (elements) =>
    for element in elements
      # iterate over each CSS property and apply to HTMLElement
      for prop, value of @options.props
        @numTransitions++
        if @options.duration > 0
          element.addEventListener(@transitionEndStr, @onTransitionEnd, false)
        else
          @onTransitionEnd(target: element)
        
        new effects.TransitionDelegate(element, prop, value, @options.duration)
    
  onTransitionEnd: (e) =>
    e.target.removeEventListener(@transitionEndStr, @onTransitionEnd, false)
    @numTransitionsComplete++
    if @numTransitionsComplete is @numTransitions      
      if @options.complete?
        @options.complete.call(@)


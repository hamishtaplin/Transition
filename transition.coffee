# TRANSITION
# ==========

# Transition is a CSS3 Transition API with jQuery fallback. 

"use strict"  

effects = Namespace("SEQ.effects")

# class of static helper properties/methods 
class effects.Transition 
  
  # list of transitionEnd event names
  @TransitionEndNames =
    WebkitTransition: 'webkitTransitionEnd'
    MozTransition: 'transitionend'
    OTransition: 'oTransitionEnd'
    msTransition: 'msTransitionEnd'
    transition: 'transitionEnd'

  # utility function for getting vendor-prefixed property     
  @GetProp = (prop) ->  
    for prefix in ["", "Webkit", "Moz", "O", "ms", "Khtml"]
      p = "#{prefix}#{prop}"
      return p if document.body.style[p]?

  @To: (options) =>
    # apply delay, if present
    t = setTimeout =>
      # if browser supports CSS3 Transitions
      if effects.Transition.GetProp("Transition")?
        # start the magic
        new effects.TransitionController(options)
      else
        # rock it old-skool
        @jqAnimate(options)
      clearTimeout(t)
    , options.delay or 0   
  
  @jqAnimate: (options) =>
    # if jQuery object
    if options.target instanceof jQuery
      # use that
      target = options.target
    else
      # create one
      target = $(options.target)

    # patch opacity transitions with fadein/out  
    if options.props.opacity?
      if options.props.opacity is 0
        target.fadeOut(options.duration, options.complete)
      if options.props.opacity is 1
        target.fadeIn(options.duration, options.complete)
      # remove opacity from property queue
      delete options.opacity

    # pass user options unti jQuery animation API
    target.animate(
      options.props
    , 
      duration: options.duration
      complete: (e) =>
        # if opacity
        if options.complete?
          options.complete.call(@)
    )
    

#=require kineticjs-viewport

$(document).ready ->
  graph = new Graph({
    container: 'canvas-container'
  })

  graph.load "/assets/test.json", () ->

  rect = new Kinetic.Rect({
    x: 10,
    y: 10,
    width: 980,
    height: 980,
    fill: '#DBDBDB',
    stroke: 'blue',
    strokeWidth: 4
  })

  graph.viewport.layer.add(rect)

  #graph.drawCourse("Comp 202", new Point(30, 30))
  #graph.drawCourse("Comp 250", new Point(120, 30))
  #graph.drawArrow(120, 100, 200, 200)


  #add the shape to the layer
  graph.update()


class Ressources
  @images: {}

  @loadImageFromJson: (data) ->
    for k0, v0 of data.style #for all the class in the style
      for k, v of v0
        if(v.background? && v.background.image? && v.background.image.src?)
          @addImage(v.background.image.src);

  @addImage: (src) ->
    if(!@images[src]?)
      image = new Image()
      image.src = src
      @images[src] = image

  #Call the given function when all images are loaded
  @onLoadImage: (callback) ->
    loadedImages = 0
    numImages = 0
    #get num of sources
    for src, image of @images
      numImages += 1
    console.debug ("num: " + numImages)

    for src, image of @images
      image.onload = ()   ->
        if (++loadedImages >= numImages)
          callback()


class Graph
  constructor: (options) ->
    defaults = {
      container: 'canvas',
      width: 700,
      height: 400
    }
    @options = $.extend({}, defaults, options)
    @viewport = new ViewPort({
      container: options.container,
      width: options.width,
      height: options.height
    })

    @ressources = {}

  load: (url, callback) ->
    $.post(url, (data) =>
      @viewport.resizeLayer(data.graph.dimension.width, data.graph.dimension.height)
      Ressources.loadImageFromJson (data)
      @style = data.style
      Ressources.onLoadImage => #Wait for the images to load
        @addNode(50, 50)
        callback()

    , "json")




  drawCourse: (course, pos) ->
    group = new Kinetic.Group({
      x: pos.x,
      y: pos.y,
      draggable: true
    })

    rect = new Kinetic.Rect({
      x: 0,
      y: 0,
      width: 70,
      height: 70,
      cornerRadius: 10,
      fill: '#DBDBDB',
      stroke: 'blue',
      strokeWidth: 4
    })

    image = new Kinetic.Image({
      x: 5,
      y: 5,
      image: @images['course.unavailable'],
      width: 20,
      height: 20

    })

    text = new Kinetic.Text({
      x: 5,
      y: 30,
      text: course,
      fontSize: 12,
      fontFamily: 'Helvetica',
      fill: 'black'
    })

    group.add(rect)
    group.add(image)
    group.add(text)
    # add the shape to the layer
    @viewport.layer.add(group)
    @update()

  addNode: (x, y, style) ->
    computedStyle = $.extend({}, @style.node, style)

    group = new Kinetic.Group({
      x: x
      y: y
      width: computedStyle.height
      height: computedStyle.width
    })

    @viewport.layer.add(group)

    node = new GraphElement(group, computedStyle, @)
    node.update()

  update: ->
    @viewport.update()

State =
  DEFAULT: 0
  HOVER: 1
  ACTIVE: 2

class GraphElement
  constructor: (@group, @style, @graph) ->
    @ishover = false
    @ustate = State.DEFAULT

    @on 'mouseover', () =>
      @ishover = true
      @ustate = State.HOVER
    @on 'mouseleave', () =>
      @ishover = false
      @ustate = State.DEFAULT
    @on 'mousedown', () =>
      console.log("DOWN")
      @ustate = State.ACTIVE
    @on 'mousedown', () =>
      if @ishover
        @ustate = State.HOVER
      else
        @ustate = State.DEFAULT

  on: (event, callback) ->
    @group.on(event, () =>
      callback()
      @update()
    )

  update: ->
    switch @ustate
      when State.DEFAULT
        @applyStyle(@style.normal)
      when State.HOVER
        @applyStyle(@style.normal, @style.hover)
      when State.ACTIVE
        @applyStyle(@style.normal, @style.active)
      else
        @applyStyle(@style.normal)
    @graph.update()

  applyStyle: (defaultStyle, stateStyle) ->
    style = $.extend(true, {}, defaultStyle, stateStyle)
    if(style.background?) #if the background property is defined
      background = @group.get(".background").first
      if(!background?)
        background = new Kinetic.Rect({
          x: 0
          y: 0
          width: @group.getWidth()
          height: @group.getHeight()
          name: 'background'

        });
        @group.add(background)

      if(style.background.border?)      #If a border is defined
        border = style.background.border;
        background.setStroke(border.color)
        background.setStrokeWidth(border.width)
      if(style.background.cornerradius?)#if the border radius is defined
        background.setCornerRadius(style.background.cornerradius)
      if(style.background.image?)       #if the background have an image
        image = style.background.image
        src = style.background.image.src
        background.setFillPatternImage(Ressources.images[src])
        if(image.offset?)
          background.setFillPatternOffset(image.offset.x, image.offset.y)
      if(style.background.gradient?)
        gradient = style.background.gradient
        angle = @computeAngle(gradient.angle)
        console.log("C: " + JSON.stringify(angle))
        background.setAttrs({
          fillLinearGradientStartPoint: angle.start,
          fillLinearGradientEndPoint: angle.end,
          fillLinearGradientColorStops: gradient.colors
        });



  computeAngle: (val) ->
    if(!val?)
      val = "top"
    switch val
      when "left"
        {
        start: [0, 0],
        end: [@style.width, 0]
        }
      when "right"
        {
        start: [@style.width, 0],
        end: [0, 0]
        }
      when "top"
        {
        start: [0, 0],
        end: [0, @style.height]
        }
      when "bottom"
        {
        start: [0, @style.height],
        end: [0, 0]
        }
      else


        tan = Math.tan(val * (Math.PI / 180))


        x = 1 / tan
        y = tan

        if(90 < val < 270)
          x = -x
        if(180 < val < 360)
          y = -y

        if(x > 1)
          x = 1
        if(x < -1)
          x = -1
        if(y > 1)
          y = 1
        if(y < -1)
          y = -1


        return {
        start: [(1 - x) * (@style.width / 2), (1 - y) * (@style.height / 2)],
        end: [(1 + x) * (@style.height / 2), (1 + y) * (@style.height / 2)]
        }


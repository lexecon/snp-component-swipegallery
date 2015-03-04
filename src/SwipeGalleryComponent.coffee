define (require, exports, module)->
  Backbone = require "backbone"
  require "epoxy"

  SuperView = MixinBackbone(Backbone.Epoxy.View)

  SwipeGallery = require 'swipeGallery'

  SwipeGalleryModel = Backbone.Epoxy.Model


  SwipeGalleryCollection = Backbone.Collection.extend
    model: SwipeGalleryModel


  SwipeGalleryItem = SuperView.extend
    template: "#SwipeGalleryItem"
    className: "swipegallery_item"


  SwipeGalleryComponent = SuperView.extend
    template: "#SwipeGalleryComponent"
    className: "swipegallery_component"

    ui:
      galleryBlock: "[data-js-block]"
      galleryList: "[data-js-list]"
      arrowLeft: "[data-js-side-left]"
      arrowRight: "[data-js-side-right]"
      controls: ".controls_overflow .control"

    events:
      "smartclick @ui.controls": "onControlClick"
      "smartclick @ui.arrowLeft": "onClickLeft"
      "smartclick @ui.arrowRight": "onClickRight"

    bindings:
      "@ui.galleryList": "collection: $collection"

    itemView: SwipeGalleryItem

    initialize: ->
      @renderAsync = $.Deferred()
      @options = {selector: @ui.galleryBlock}
      @onChangeGallery = null
      @options.onChange = _.bind @onChange, this
      @collection ?= new SwipeGalleryCollection
      # Для создания галлереи
      @listenToOnce @collection, 'reset', @onChangeCollection

    render: ->
      @renderAsync.resolve()
      # Чтобы сначала вызывался обработчик для создания элемента (в initialize view) а после обработчик наш
      @listenTo @collection, 'reset', @onChangeCollection
      @listenTo @collection, 'add', @onChangeCollection
      @listenTo @collection, 'remove', @onChangeCollection

    onChange: (index, max, itemMas, dirrection)->
      if @onChangeGallery
        galleryModels = []
        _.each itemMas, (item)=>
          galleryModels.push @collection.models[item.index]
        @onChangeGallery(index, galleryModels, dirrection)

    onChangeCollection: (el1, el2)->
      @renderAsync.done =>
        if @galery
          @galery.update()
        else
          @galery = new SwipeGallery @options

    setOptions: (options)->
      _.extend @options, options

    onControlClick: (e)->
      @galery.goTo $(e.currentTarget).index()

    onClickLeft: ->
      @galery.prev()
    onClickRight: ->
      @galery.next()

    onShow:->
      $(window).on "resize.swipe"+@cid,  =>
        if @galery
          @galery.update()

    onClose:->
      $(window).off "resize.swipe"+@cid

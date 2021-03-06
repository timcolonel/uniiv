$(document).ready ()->
  $('#moveableboxsortcourse').each ()->
    top = $(this).attr('data-topspacing')

    $(this).sticky({topSpacing: parseInt(top)})

  $(document).on('searchAjaxComplete', '#search_new_course', () ->
    $('#search-output-container').sortable({
      group: 'course-sort'
    })
  )

  $(document).on('mouseenter', 'li.dependency.notsortable', () ->
    course_id = $(this).children(':first').data('course-id')
    $("div.sortable_list_container >  ul > li > div[data-course-id=" + course_id + "] ").parent().addClass('highlight')
  )
  $(document).on('mouseleave', 'li.dependency.notsortable', () ->
    course_id = $(this).children(':first').data('course-id')
    $("div.sortable_list_container > ul > li > div[data-course-id=" + course_id + "] ").parent().removeClass('highlight')
  )

  $('.sortable').each ()->
    handleSortable($(this))


getURLParameters = (params) ->
  return {} unless params?
  result = {}
  sURLVariables = params.split('&')
  for variable in sURLVariables
    sParameterName = variable.split('=')
    result[sParameterName[0]] = sParameterName[1]
  return result

checkDependencies = (course_id, remove = false) ->
  $('li.dependency').each () ->
    if $(this).children().attr('data-course-id') == course_id
      if remove
        $(this).removeClass('notsortable')
      else
        $(this).addClass('notsortable')


handleSortable = (element) ->
  $(element).on 'mouseenter', '.btn', () ->
    $(this).attr('data-over', true)
  $(element).on 'mouseleave', '.btn', () ->
    $(this).attr('data-over', false)

  adjustment = {}
  drop = true
  group = element.attr('data-group')
  if element.hasClass('no-drop')
    drop = false
  element.sortable({
    group: group
    drop: drop
    itemSelector: 'li:not(.notsortable)'
    onMousedown: ($item, _super, event) ->
      cancel = false
      if event.target.nodeName == 'INPUT' or event.target.nodeName == 'SELECT'
        cancel = true
      unless cancel
        $item.find('.btn').each () ->
          if $(this).attr('data-over') == 'true'
            cancel = true
            return

      unless cancel
        event.preventDefault()

      return not cancel


    onDragStart: ($item, container, _super) -> #Reposition the draggin element relative from where it was grabbed
      ul = $item.closest('ul')
      $item.data('origin-container', ul)
      if ul.hasClass('duplicate')
        $item.clone().insertAfter($item)
      offset = $item.offset()
      pointer = container.rootGroup.pointer

      adjustment = {
        left: pointer.left - offset.left,
        top: pointer.top - offset.top
      }
      _super($item, container)

    onDrag: ($item, position) ->
      $item.css({
        left: position.left - adjustment.left,
        top: position.top - adjustment.top
      })
    onDrop: ($item, container, _super) ->
      _super($item, container)
      ul = $item.closest('ul')
      if $item.data('origin-container') == ul #Dont do anything if drop on the same box
        return

      update_url = ul.attr('data-update-url')
      type = ul.attr('data-type')
      course_id = $item.children().attr('data-course-id')
      params = ul.attr('data-params')
      remove = false
      need_reload = false
      remove = true if type == 'delete'
      need_reload = true if $item.children().attr('data-need-reload') == 'true'

      parameters = $.extend(getURLParameters(params), {
        course_id: course_id
        remove: remove
        need_reload: need_reload
      })
      if remove
        $item.remove()
      loading_anim = $($("#loading_animation").html()).appendTo($item)
      loading_anim.show()
      $.post(update_url, parameters).success((data) ->
        ajaxPopupPush(data.message)
        console.log('ned:' + need_reload)
        if need_reload
          tmpItemp = $item.after(data.html)
          $item.remove()
          $item = tmpItemp

        #Remap event
        $item.find('ul.sortable').each () ->
          handleSortable($(this))

        if data.invalid_courses?
          $('div[data-course-id]').each ->
            if data.invalid_courses.indexOf(parseInt($(this).attr('data-course-id'))) == -1
              $(this).parent().removeClass('invalid-time')
            else
              $(this).parent().addClass('invalid-time')

        checkDependencies(course_id, remove)
        loading_anim.remove()
      ).error (error) ->
        console.log(error)
  })


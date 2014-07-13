window.Toolkit = Ember.Application.create()

Toolkit.Router.map( () ->
  # put your routes here
)

Toolkit.IndexRoute = Ember.Route.extend({
  model: () -> ['red', 'yellow', 'blue']
})

Array::remove = (v) -> $.grep @,(e)->e!=v

$(document).ready ->
  $('.js-warning').hide()
  
  $('.lexicons .chosen-select').chosen()
  
  $('.tags .chosen-select').chosen
    create_option: true
    persistent_create_option: true
    skip_no_results: true
  
  $('.dropdown-toggle').click( () ->
    target = $(this).next('.dropdown')
    
    if $(target).is(":hidden")
      $(target).slideDown({ duration: 600, easing: 'swing' })
    else
      $(target).slideUp({ duration: 600, easing: 'swing' })
  )
  
  $('.box-select').each( () ->
    target = $('#' + $(this).attr('data-target'))
    
    if $(this).attr('data-multi-select') == "true"
      values = []
      
      $(this).children('.btn-primary').each( () -> values.push( $(this).attr('data-value') ) )
      $(this).data('values', values)
      
      $(target).val(values.join(","))
  )
  
  $('.box-select .btn').click( () ->
    parent = $(this).parent('.box-select')
    target = $('#' + $(parent).attr('data-target'))
    
    if $(parent).attr('data-multi-select') == "true"
      if $(this).hasClass('btn-primary')
        values = $(parent).data('values').remove($(this).attr('data-value'))
        $(parent).data('values', values)
        $(target).val(values.join(","))
        $(this).addClass('btn-default')
        $(this).removeClass('btn-primary')
      else
        values = $(parent).data('values')
        values.push($(this).attr('data-value'))
        $(target).val(values.join(","))
        $(this).removeClass('btn-default')
        $(this).addClass('btn-primary')
    else
      if $(this).hasClass('btn-primary')
        $(target).val(0)
        $(this).removeClass('btn-primary')
        $(this).addClass('btn-default')
      else
        $(target).val($(this).attr('data-value'))
        $(this).siblings('.btn-primary').addClass('btn-default')
        $(this).siblings('.btn-primary').removeClass('btn-primary')
        $(this).removeClass('btn-default')
        $(this).addClass('btn-primary')
  )
  
  # KEYBOARD
  $(window).resize( () ->
    $('.keyboard').css('width', parseInt($('.controls textarea').first().css('width')) + 12)
  )
  
  $(window).resize()
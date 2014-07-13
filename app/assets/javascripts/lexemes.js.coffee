$(document).ready ->
  window.num_definitions = $('.form-group.definition').length
  
  window.reorder_definitions = ->
    i = 1
    $('.form-group.definition').each( ->
      $(this).children('label.definition').attr('for', 'definition_' + i)
      $(this).children('textarea.definition').attr('name', 'definition_' + i)
      $(this).children('label.notes').attr('for', 'notes_' + i)
      $(this).children('textarea.notes').attr('name', 'notes_' + i)
      i++
    )
  
  window.add_listener = (obj) ->
    $(obj).click () ->
      window[$(this).data('listener')](this)
  
  window.add_definition = (obj) ->
    num_definitions++
    
    $(obj).before(
      """
      <div class='clear clearfix form-group definition'>
        <label class='definition' for='definition_#{num_definitions}"'>Definition</label>
        <textarea class='definition form-control' name='definition_#{num_definitions}' rows='4'></textarea>
        <span class='btn btn-default' data-listener='add_notes'>+ Add usage notes</span>
        <span class='btn btn-danger'  data-listener='remove_definition'>- Remove definition</span>
      </div>
      """
    )
    
    add_listener($('.btn[data-listener=add_notes]'))
    add_listener($('.btn[data-listener=remove_definition]'))
  
  window.remove_definition = (obj) ->
    $(obj).parent().remove()
  
  window.add_notes = (obj) ->
    $(obj).after(
      """
      <div class='clear clearfix form-group note'>
        <label class='notes' for='notes_#{$(obj).siblings('textarea').attr('name').match(/[0-9]+/)}'>Usage Notes</label>
        <textarea class='notes form-control' name='notes_#{$(obj).siblings('textarea').attr('name').match(/[0-9]+/)}' rows='4'></textarea>
      </div>
      <span class='btn btn-danger' data-listener='remove_notes'>- Remove notes</span>
      """
    )
    
    $(obj).css('display', 'none')
    
    add_listener($('.btn[data-listener=remove_notes]'))
  
  window.remove_notes = (obj) ->
    $(obj).siblings('.btn[data-listener=add_notes]').css('display', 'inline')
    $(obj).siblings('div.note').remove()
    $(obj).remove()
  
  $('.btn[data-listener]').each( ->
    add_listener($(this))
  )
{$, EditorView, View} = require 'atom'
S = require 'string'

noop = ->

method = (delegate, method) ->
  delegate?[method]?.bind(delegate) or noop

module.exports =
class PromptView extends View
  @attach: -> new PromptView

  @content: ->
    @div class: 'emmet-prompt mini', =>
      # @label class: 'emmet-prompt__label', outlet: 'label'
      @div class: 'emmet-prompt__input', =>
        @subview 'panelInput', new EditorView(mini: true)

  initialize: () ->
    @panelEditor = @panelInput.getEditor()
    @on 'core:confirm', => @confirm()
    @on 'core:cancel', => @cancel()

  show: (@delegate={}) ->
    @editor = @delegate.editor
    @editorView = @delegate.editorView
    @panelInput.setPlaceholderText @delegate.label
    @attach()

  attach: ->
    @attached = true
    @previouslyFocusedElement = $(':focus')
    # atom.workspaceView.append(this)
    atom.workspaceView.prependToBottom(this)
    @panelInput.focus()
    @panelInput.setText('')
    @trigger 'attach'
    method(@delegate, 'show')()

  confirm: ->
    @trigger 'confirm'
    text = @remove_underscore_and_extensions @panelEditor.getText()
    method(@delegate, 'confirm')(text)
    @detach()

  cancel: ->
    @trigger 'cancel'
    method(@delegate, 'cancel')()
    @detach()

  detach: ->
    super
    @trigger 'detach'
    method(@delegate, 'hide')()

  remove_underscore_and_extensions: (text) ->
    text = S(text).chompLeft '_'
    text = S(text).chompRight '.erb'
    text = S(text).chompRight '.html'
    text.s

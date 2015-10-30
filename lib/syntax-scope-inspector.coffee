SyntaxScopeInspectorView = require './syntax-scope-inspector-view'
{CompositeDisposable} = require 'atom'

module.exports = SyntaxScopeInspector =
  syntaxScopeInspectorView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @syntaxScopeInspectorView = new SyntaxScopeInspectorView(state.syntaxScopeInspectorViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @syntaxScopeInspectorView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'syntax-scope-inspector:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @syntaxScopeInspectorView.destroy()

  serialize: ->
    syntaxScopeInspectorViewState: @syntaxScopeInspectorView.serialize()

  toggle: ->
    console.log 'SyntaxScopeInspector was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()

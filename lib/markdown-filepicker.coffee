module.exports =
  config:
    fpApiKey:
      title: "fpApiKey"
      type: 'string'
      description: "FilePicker API Key"
      default: ""

  activate: (state) ->
    @attachEvent()

  attachEvent: ->
    workspaceElement = atom.views.getView(atom.workspace)
    workspaceElement.addEventListener 'keydown', (e) =>
      # cmd + paste
      if (e.metaKey && e.keyCode == 86)

        clipboard = require('clipboard')
        img = clipboard.readImage()
        return if img.isEmpty()

        # get base64 encode
        image_buffer = img.toDataURL().split(',', 2)[1]

        # insert loading text
        editor = atom.workspace.getActiveTextEditor()
        range = editor.insertText('Uploading...');

        @postToFilePicker image_buffer, (response_message) ->
          range[0].end.column = 100 # replace whole row
          editor.setTextInBufferRange(range[0], response_message)

  postToFilePicker: (img, callback) ->

    filepicker = require('filepicker-js')

    fpApiKey = atom.config.get('markdown-filepicker.fpApiKey')
    filepicker.setKey(fpApiKey)

    # use timestamp as filename
    unixTime = require('unix-time')
    timestamp = unixTime new Date

    filepicker.store img, { persist: true, base64decode: true, mimetype: 'image/png', filename: "#{timestamp}.png"  }, ((Blob) ->
      console.dir(Blob)
      callback("![](" + Blob.url + ")")
      ), ((FPError) ->
        callback('error:' + FPError.toString() )
      ), (progress) ->
        uploading_messge =  'Uploading... ' + progress + '%'
        console.log  uploading_messge
        callback(uploading_messge)

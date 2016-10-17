try
  {Robot,Adapter,TextMessage,User} = require 'hubot'
catch
  prequire = require('parent-require')
  {Robot,Adapter,TextMessage,User} = prequire 'hubot'
request = require 'request'
pushEP = 'https://api.line.me/v2/bot/message/push'
replyEP = 'https://api.line.me/v2/bot/message/reply'



class LineMessageApiAdapter extends Adapter
    run: ->
        @endpoint = process.env.HUBOT_ENDPOINT ? '/hubot/incoming'
        @channelAccessToken = process.env.LINE_CHANNEL_ACCESS_TOKEN ? ''
        unless @channelAccessToken?
            @robot.logger.emergency "LINE_CHANNEL_ACCESS_TOKEN is required"
            process.exit 1
        @robot.router.post @endpoint, (req, res) =>
            console.log "callback body: #{JSON.stringify(req.body)}"
            # TODO: validate signeture
            events = req.body.events
            for event in events
                {replyToken, type, source, message} = event
                if message.type isnt "text"
                    console.log "This is not 'text' message."
                    # TODO: text以外の処理
                switch source.type
                    when "user"
                        from = source.userId
                    when "group"
                        from = source.groupId
                    when "room"
                        from = source.roomId
                text = message.text ? ''
                console.log "from: #{source.type} => #{from}"
                console.log "text: #{text}"
                user = @robot.brain.userForId replyToken
                @receive new TextMessage(user, text, message.id)
            @emit 'connected'

    send: (envelope, strings...) ->
        headers =
            "Content-Type": "application/json"
            "Authorization": "Bearer #{@channelAccessToken}"
        to = envelope.user.id
        data =
            to: to
            messages: []
        for string in strings.slice(0,5)
            data.messages = data.messages.concat
                type: "text"
                text: string.text
        options =
            url: pushEP
            headers: headers
            method: 'POST'
            proxy: process.env.FIXIE_URL ? ''
            body: JSON.stringify(data)
        request options, (err, response, body) ->
            throw err if err
            if response.statusCode is 200
              console.log "success"
              console.log body
            else
              console.log "response error: #{response.statusCode}"
              console.log body
    reply: (envelope, strings...) ->
        for string in strings
            switch string.type
                when 'text'
                    data = @getDataForReplyText(envelope, string)
                when 'image'
                    data = @getDataForReplyImage(envelope, string)
                when 'buttons'
                    data = @getDataForReplyButtons(envelope, string)
                when 'carousel'
                    data = @getDataForReplyCarousel(envelope, string)
            console.log data
            request
                url: replyEP
                headers:
                    "Content-Type": "application/json"
                    "Authorization": "Bearer #{@channelAccessToken}"
                method: 'POST'
                proxy: process.env.FIXIE_URL ? ''
                body: JSON.stringify(data),
                (err, response, body) ->
                    throw err if err
                    if response.statusCode is 200
                      console.log "success"
                      console.log body
                    else
                      console.log "response error: #{response.statusCode}"
                      console.log body

    _getDataForReply: (envelope) ->
        replyToken = envelope.user.id
        data =
            replyToken: replyToken
            messages: []
        return data

    getDataForReplyText: (envelope, string) ->
        data = @_getDataForReply(envelope)
        data.messages = data.messages.concat
            type: "text"
            text: string.content
        return data

    getDataForReplyImage: (envelope, string) ->
        data = @_getDataForReply(envelope)
        data.messages = data.messages.concat
            type: "image"
            originalContentUrl: string.content.original
            previewImageUrl: string.content.preview
        return data

    getDataForReplyButtons: (envelope, string) ->
        data = @_getDataForReply(envelope)
        data.messages = data.messages.concat
            type: 'template'
            altText: 'this is a buttons template'
            template:
                type: 'buttons'
                thumbnailImageUrl: string.content.image
                title: string.content.title
                text: string.content.text
                actions: string.content.actions
        return data

    getDataForReplyCarousel: (envelope, string) ->
        data = @_getDataForReply(envelope)
        columns = string.content.map((item) ->
            thumbnailImageUrl: item.image
            title: item.title
            text: item.text
            actions: item.actions
        )
        data.messages = data.messages.concat
            type: 'template'
            altText: 'this is a Carousel template'
            template:
                type: 'carousel'
                columns: columns
        return data

exports.use = (robot) ->
    new LineMessageApiAdapter(robot)

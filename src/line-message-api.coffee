try
    {Robot,Adapter,TextMessage,User} = require "hubot"
catch
    prequire = require "parent-require"
    {Robot,Adapter,TextMessage,User} = prequire "hubot"
request = require "request"
pushEP = "https://api.line.me/v2/bot/message/push"
replyEP = "https://api.line.me/v2/bot/message/reply"
getContentEP = "https://api.line.me/v2/bot/message/%s/content"

class LineMessageApiAdapter extends Adapter
    data: {}
    run: ->
        @endpoint = process.env.HUBOT_ENDPOINT ? "/hubot/incoming"
        @channelAccessToken = process.env.LINE_CHANNEL_ACCESS_TOKEN ? ""
        unless @channelAccessToken?
            @robot.logger.emergency "LINE_CHANNEL_ACCESS_TOKEN is required"
            process.exit 1
        @robot.router.post @endpoint, (req, res) =>
            console.log "callback body: #{JSON.stringify(req.body)}"
            # TODO: validate signeture
            events = req.body.events
            for event in events
                {replyToken, type, source, message} = event
                switch source.type
                    when "user"
                        from = source.userId
                    when "group"
                        from = source.groupId
                    when "room"
                        from = source.roomId
                switch message.type
                    when "text", "postback"
                        text = message.text ? ""
                        console.log "from: #{source.type} => #{from}"
                        console.log "text: #{text}"
                        user = @robot.brain.userForId from
                        user.replyToken = replyToken
                        @receive new TextMessage(user, text, message.id)
                    when "image"
                        text = ""
                        user = @robot.brain.userForId from
                        user.replyToken = replyToken
                        @receive new ImageMessage(user, text, message.id)
                    else
                        console.log "This type is not supported.(#{type})"
                    # TODO: text, postback, image以外の処理
            @emit "connected"

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
            method: "POST"
            proxy: process.env.FIXIE_URL ? ""
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
        @_updateDataForReply(envelope)
        for string in strings
            switch string.type
                when "text"
                    @updateDataForReplyText(string, @data)
                when "image", "video"
                    @updateDataForReplyImageVideo(string, @data)
                when "audio"
                    @updateDataForReplyAudio(string, @data)
                when "location"
                    @updateDataForReplyLocation(string, @data)
                when "sticker"
                    @updateDataForReplySticker(string, @data)
                when "buttons"
                    @updateDataForReplyButtons(string, @data)
                when "carousel"
                    @updateDataForReplyCarousel(string, @data)
                when "confirm"
                    @updateDataForReplyConfirm(string, @data)
                else
                    @robot.logger.emergency "Unrecognized type #{string.type}"
                    process.exit 1
        console.log @data
        request
            url: replyEP
            headers:
                "Content-Type": "application/json"
                "Authorization": "Bearer #{@channelAccessToken}"
            method: "POST"
            proxy: process.env.FIXIE_URL ? ""
            body: JSON.stringify(@data),
            (err, response, body) ->
                throw err if err
                if response.statusCode is 200
                  console.log "success"
                  console.log body
                else
                  console.log "response error: #{response.statusCode}"
                  console.log body

    _updateDataForReply: (envelope) ->
        replyToken = envelope.user.replyToken
        @data =
            replyToken: replyToken
            messages: []

    updateDataForReplyText: (string, data) ->
        for content in string.contents
            data.messages.push
                type: "text"
                text: content

    updateDataForReplyImageVideo: (string, data) ->
        for content in string.contents
            data.messages.push
                type: string.type
                originalContentUrl: content.original
                previewImageUrl: content.preview

    updateDataForReplyAudio: (string, data) ->
        for content in string.contents
            data.messages.push
                type: string.type
                originalContentUrl: content.original
                # TODO: validation number
                duration: content.duration

    updateDataForReplyLocation: (string, data) ->
        for content in string.contents
            data.messages.push
                type: "location"
                title: content.title
                address: content.address
                # TODO: validation number
                latitude: content.latitude
                longitude: content.longitude

    updateDataForReplySticker: (string, data) ->
        for content in string.contents
            data.messages.push
                type: string.type
                packageId: content.package
                sticker: content.sticker

    updateDataForReplyButtons: (string, data) ->
        for content in string.contents
            data.messages.push
                type: "template"
                altText: string.altText ? "Hello Line Bot"
                template:
                    type: "buttons"
                    thumbnailImageUrl: content.image
                    title: content.title
                    text: content.text
                    actions: content.actions

    updateDataForReplyCarousel: (string, data) ->
        columns = []
        for content in string.contents
            columns.push
                thumbnailImageUrl: content.image
                title: content.title
                text: content.text
                actions: content.actions
        data.messages.push
            type: "template"
            altText: string.altText ? "Hello Line Bot"
            template:
                type: "carousel"
                columns: columns

    updateDataForReplyConfirm: (string, data) ->
        for content in string.contents
            data.messages.push
                type: "template"
                altText: string.altText ? "Hello Line Bot"
                template:
                    type: "confirm"
                    text: content.text
                    actions: content.actions

class ContentMessage extends TextMessage
    getContent: (callback) ->
        messageId = this.id
        @channelAccessToken = process.env.LINE_CHANNEL_ACCESS_TOKEN ? ""
        url = getContentEP.replace('%s', messageId)
        request
            url: url
            headers:
                "Content-Type": "application/json"
                "Authorization": "Bearer #{@channelAccessToken}"
            method: "GET"
            proxy: process.env.FIXIE_URL ? ""
            encoding: null
            (err, response, body) ->
                throw err if err
                if response.statusCode is 200
                  console.log "success"
                  callback(body)
                else
                  console.log "response error: #{response.statusCode}"
                  console.log body

class ImageMessage extends ContentMessage

exports.use = (robot) ->
    new LineMessageApiAdapter(robot)
exports.ImageMessage = ImageMessage

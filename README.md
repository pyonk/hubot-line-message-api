# hubot-line-message-api

## 設定
### 必須
* LINE_CHANNEL_ACCESS_TOKEN
    * lineアカウントのBasic Infomationにある`Channel Access Token`の値を設定してください。

### 任意
* HUBOT_ENDPOINT
    * defaultで/hubot/incomingになってます。
    * 自由に設定していただいて大丈夫です。
* FIXIE_URL
    * herokuで走らす場合は必須かなと思います。
    * [Fixie](https://elements.heroku.com/addons/fixie)というアドオンを使います。
    * `$ heroku addons:create fixie:tricycle`を叩くと自動で設定されています。
    * 出力されるIPアドレスを`Server IP Whitelist`に設定してあげてください。

## できること
今のところpushで送信は対応できておらず、返信しかできません。

* 返信
    * Text

    [https://devdocs.line.me/ja/#text](https://devdocs.line.me/ja/#text)

    ```coffee
    module.exports = (robot) ->
        robot.hear /^テキスト$/, (res) ->
            res.reply
                type: 'text'
                contents: ['nyaa']
    ```
    * Image or Video

    [https://devdocs.line.me/ja/#image](https://devdocs.line.me/ja/#image)
    [https://devdocs.line.me/ja/#video](https://devdocs.line.me/ja/#video)

    ```coffee
    module.exports = (robot) ->
        robot.hear /^画像$/, (res) ->
            res.reply
                type:'image'# 'video'
                content: [
                    original: 'https://example.com/images/image.jpg'
                    preview: 'https://example.com/images/image.jpg'
                ]
    ```
    * Button

    [https://devdocs.line.me/ja/#buttons](https://devdocs.line.me/ja/#buttons)

    ```coffee
    module.exports = (robot) ->
        robot.hear /^テキスト$/, (res) ->
            res.reply
                type: 'buttons'
                altText: 'hogehoge'
                contents: [
                    image: 'https://example.com/images/image.jpg'
                    title: 'this is Buttons'
                    text: 'buttons description'
                    actions:[
                        type: 'uri'
                        label: 'Open in Browser'
                        uri: 'http://example.com/'
                    ]
                ]
    ```
    * Confirm

    [https://devdocs.line.me/ja/#confirm](https://devdocs.line.me/ja/#confirm)

    ```coffee
    module.exports = (robot) ->
        robot.hear /^コンファーム$/, (res) ->
            res.reply
                type: 'confirm'
                altText: 'hogehoge'
                contents: [
                    text: 'confirm description'
                    actions:{
                        type: 'message'
                        label: 'Yes'
                        text: 'yes'
                    },{
                        type: 'message'
                        label: 'No'
                        text: 'no'
                    }
                ]
    ```
    * Carousel

    [https://devdocs.line.me/ja/#carousel](https://devdocs.line.me/ja/#carousel)

    ```coffee
    module.exports = (robot) ->
        robot.hear /^カルーセル$/, (res) ->
            res.reply
                type: 'carousel'
                altText: 'hogehoge'
                contents: [
                    image: 'https://example.com/images/image.jpg'
                    title: 'this is Carousel'
                    text: 'carousel description'
                    actions:[
                        type: 'uri'
                        label: 'Open in Browser'
                        uri: 'http://example.com/'
                    ],
                    image: 'https://example.com/images/image.jpg'
                    title: 'this is Carousel'
                    text: 'carousel description'
                    actions:[
                        type: 'uri'
                        label: 'Open in Browser'
                        uri: 'http://example.com/'
                    ]...
                ]
    ```
    * くみあわせ

    ```coffee
    module.exports = (robot) ->
        robot.hear /^くみあわせ$/, (res) ->
            res.reply {
                type: 'text'
                contents: ['nyaa']
            },
            {
                type: 'buttons'
                contents: [
                    image: 'https://example.com/images/image.jpg'
                    title: 'this is Buttons'
                    text: 'buttons description'
                    actions: [
                        type: 'uri'
                        label: 'Open in Browser'
                        uri: 'http://example.com/'
                    ]
                ]
            }
    ```

* コンテンツ受信
    * イメージ受信

    ```coffee
    {ImageMessage} = require 'hubot-line-message-api'
    
    robot.hear /.*/, (res) ->
        if res.message instanceof ImageMessage
            res.message.getContent (content) ->
                fs.writeFile 'sample.jpg', content, 'binary'
    ```

* Postback(ユーザのボタン押下など）
   ```coffee
    {PostbackMessage} = require 'hubot-line-message-api'

    robot.hear /.*/, (res) ->
        if res.message instanceof PostbackMessage
            # postback.data
            console.log(res.message.data)
   ```

# 注意点
* `contents.length <= 5`にしないとLINEに怒られます。
    * くみあわせて使う場合はcontents.lengthを足し算した値が5を超えないようにしないと怒られます。
* 画像のURLなどはhttpsでないと怒られます。

# Special Thanks
@shouta-dev Thank you for your contibutions! 

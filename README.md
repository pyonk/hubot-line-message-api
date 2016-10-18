# hubot-line-message-api
## できること
* 返信
    * テキスト
    [https://devdocs.line.me/ja/#text](https://devdocs.line.me/ja/#text)
    ```
    res.reply
        type: 'text'
        content: 'nyaa'
    ```
    * 画像
    [https://devdocs.line.me/ja/#image](https://devdocs.line.me/ja/#image)
    ```
    res.reply
        type:'image'
        content:
            original: 'https://example.com/images/image.jpg'
            preview: 'https://example.com/images/image.jpg'
    ```
    * ボタン
    [https://devdocs.line.me/ja/#buttons](https://devdocs.line.me/ja/#buttons)
    ```
    res.reply
        type: 'buttons'
        altText: 'hogehoge'
        content:
            image: 'https://example.com/images/image.jpg'
            title: 'this is Buttons'
            text: 'buttons description'
            actions:[
                type: 'uri'
                label: 'Open in Browser'
                uri: 'http://example.com/'
            ]
    ```
    * カルーセル
    [https://devdocs.line.me/ja/#carousel](https://devdocs.line.me/ja/#carousel)
    ```
    res.reply
        type: 'carousel'
        altText: 'hogehoge'
        content:[
            image: 'https://example.com/images/image.jpg'
            title: 'this is Buttons'
            text: 'buttons description'
            actions:[
                type: 'uri'
                label: 'Open in Browser'
                uri: 'http://example.com/'
            ],
            image: 'https://example.com/images/image.jpg'
            title: 'this is Buttons'
            text: 'buttons description'
            actions:[
                type: 'uri'
                label: 'Open in Browser'
                uri: 'http://example.com/'
            ]...
        ]
    ```


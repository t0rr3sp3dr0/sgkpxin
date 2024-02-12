## JetBrains Toolbox Public Feed

```sh
curl -Ls 'https://download.jetbrains.com/toolbox/feeds/v1/public-feed.feed.xz.signed' | openssl smime -verify -noverify -inform DER | xzcat | jq
```

## JetBrains Toolbox Third-Party Feed

```sh
curl -Ls 'https://download.jetbrains.com/toolbox/feeds/v1/thirdparty-feed.feed.xz.signed' | openssl smime -verify -noverify -inform DER | xzcat | jq
```

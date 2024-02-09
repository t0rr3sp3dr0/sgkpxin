## JetBrains Toolbox Public Feed

```sh
curl -Ls 'https://download.jetbrains.com/toolbox/feeds/v1/public-feed.feed.xz.signed' | dd bs='1' skip='64' | xzcat | jq
```

## JetBrains Toolbox Third-Party Feed

```sh
curl -Ls 'https://download.jetbrains.com/toolbox/feeds/v1/thirdparty-feed.feed.xz.signed' | dd bs='1' skip='61' | xzcat | jq
```

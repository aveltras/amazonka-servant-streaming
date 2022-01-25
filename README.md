# amazonka-servant-streaming

Minimal repo trying to achieve file streaming from AWS S3 through Servant.

To use this, you have to create a `.env` file at the root of the project with the following values filling `AWS_ACCESS_KEY_ID` AND `AWS_SECRET_ACCESS_KEY` appropriately:

```
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=eu-west-3
AWS_DEFAULT_REGION=eu-west-3
```

This repository comes with an existing bucket `amazonka-servant-streaming` with a file named `haskell.png` to test the streaming.

To run the server, simply use
```sh
nix-shell --run 'ghcid -T :main'
```

Currently, the streaming doesn't work and the following error is encountered during the endpoint access:

```
HttpExceptionRequest Request {
  host                 = "amazonka-servant-streaming.s3.eu-west-3.amazonaws.com"
  port                 = 443
  secure               = True
  requestHeaders       = [("Host","amazonka-servant-streaming.s3.eu-west-3.amazonaws.com"),("X-Amz-Date","20220125T094901Z"),("X-Amz-Content-SHA256","e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"),("Authorization","<REDACTED>")]
  path                 = "/haskell.png"
  queryString          = ""
  method               = "GET"
  proxy                = Nothing
  rawBody              = False
  redirectCount        = 0
  responseTimeout      = ResponseTimeoutMicro 70000000
  requestVersion       = HTTP/1.1
}
 ConnectionClosed
 ```

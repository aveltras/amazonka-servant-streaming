# amazonka-servant-streaming

Minimal repo trying to achieve file streaming from AWS S3 through Servant using Amazonka library.

To use this, you have to create a `.env` file at the root of the project with the following values filling `AWS_ACCESS_KEY_ID` AND `AWS_SECRET_ACCESS_KEY` appropriately:

```
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=eu-west-3
AWS_DEFAULT_REGION=eu-west-3
```

This repository comes with an existing bucket `amazonka-servant-streaming` with a file named `haskell.png` to test the streaming.

The test file is available here: https://amazonka-servant-streaming.s3.eu-west-3.amazonaws.com/haskell.png

To run the server, simply use

```sh
nix-shell --run 'ghcid -T :main'
```

The server provides two endpoints.

One accessible at http://localhost:3030/two-steps which first downloads the file from s3 and then streams it to the client.
This works but is suboptimal as we need an intermediary file so the client can't start downloading before the server finishes fetching from s3.

Another one accessible at http://localhost:3030/one-step which tries to achieve the desired result (no intermediary file) but is currently failing.
The streaming doesn't work and the following error is encountered when accessing the endpoint:

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

## Related information

- https://github.com/domenkozar/servant-streaming-amazonka (seems outdated)
- https://github.com/haskell-servant/servant/blob/master/servant-conduit/example/Main.hs
- https://github.com/brendanhay/amazonka/blob/main/examples/src/S3.hs
- https://github.com/brendanhay/amazonka/issues/466
- https://github.com/brendanhay/amazonka/issues/463

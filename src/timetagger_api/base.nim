import yahttp

# TYPES ----------------------------------------------------------

type RequestResult* = object
  Success*: bool
  Res*: Response
  Error*: string

type BaseHelper* = object
  Url*: string
  Token*: string
  Timeout*: int
  DoGet*: proc(urlPath: string): RequestResult
  DoPut*: proc(urlPath: string, body: string): RequestResult

# ----------------------------------------------------------------
# PROCS ----------------------------------------------------------

proc DoGet*(b: var BaseHelper, urlPath: string): RequestResult =
  var res = get(
    urlPath,
    headers = {"Content-Type": "application/json", "authtoken": b.Token},
    ignoreSsl = true,
    timeout = b.Timeout,
    sslContext = nil
  )

  if res.ok():
    return RequestResult(
      Success: true,
      Res: res,
      Error: ""
    )

  return RequestResult(
    Success: false,
    Res: res,
    Error: res.body
  )


proc DoPut*(b: var BaseHelper, urlPath: string, body: string): RequestResult =
  var res = put(
    urlPath,
    headers = {"authtoken": b.Token},
    body = body,
    ignoreSsl = true,
    timeout = b.Timeout,
    sslContext = nil
  )

  if res.ok():
    return RequestResult(
      Success: true,
      Res: res,
      Error: ""
    )

  return RequestResult(
    Success: false,
    Res: res,
    Error: res.body
  )

# ----------------------------------------------------------------

import std/httpclient

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
  var client = newHttpClient(timeout = b.Timeout)
  try:
    var res = request(
      client, 
      b.Url & urlPath, 
      HttpMethod.HttpGet, 
      headers = newHttpHeaders({"Content-Type": "application/json", "authtoken": b.Token})
    )

    if is2xx(res.code) or is3xx(res.code):
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
  except HttpRequestError as hre:
    return RequestResult(
      Success: false,
      Res: nil,
      Error: hre.msg
    )
  except ProtocolError as pe:
    return RequestResult(
      Success: false,
      Res: nil,
      Error: pe.msg
    )
  finally:
    client.close()


proc DoPut*(b: var BaseHelper, urlPath: string, body: string): RequestResult =
  var client = newHttpClient(timeout = b.Timeout)
  try:
    var res = request(
      client, 
      b.Url & urlPath, 
      HttpMethod.HttpPut, 
      headers = newHttpHeaders({"authtoken": b.Token}),
      body = body
    )

    if is2xx(res.code) or is3xx(res.code):
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
  except HttpRequestError as hre:
    return RequestResult(
      Success: false,
      Res: nil,
      Error: hre.msg
    )
  except ProtocolError as pe:
    return RequestResult(
      Success: false,
      Res: nil,
      Error: pe.msg
    )
  finally:
    client.close()

# ----------------------------------------------------------------

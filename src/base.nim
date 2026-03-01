import std/httpclient

# TYPES ----------------------------------------------------------

type RequestResult* = object
  Success*: bool
  Error*: string
  Res*: Response

type BaseHelper* = object
  Url*: string
  Token*: string
  Timeout*: int
  DoLogging*: bool

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

    if b.DoLogging:
      echo "DoGet ------"
      echo res.status
      echo res.headers
      echo res.body()
      echo "------------"

    if is2xx(res.code) or is3xx(res.code):
      return RequestResult(
        Success: true,
        Error: "",
        Res: res
      )

    return RequestResult(
      Success: false,
      Error: res.body,
      Res: res
    )
  except HttpRequestError as hre:
    return RequestResult(
      Success: false,
      Error: hre.msg,
      Res: nil
    )
  except ProtocolError as pe:
    return RequestResult(
      Success: false,
      Error: pe.msg,
      Res: nil
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

    if b.DoLogging:
      echo res.status
      echo res.headers
      echo res.body()

    if is2xx(res.code) or is3xx(res.code):
      return RequestResult(
        Success: true,
        Error: "",
        Res: res
      )

    return RequestResult(
      Success: false,
      Error: res.body,
      Res: res
    )
  except HttpRequestError as hre:
    return RequestResult(
      Success: false,
      Error: hre.msg,
      Res: nil
    )
  except ProtocolError as pe:
    return RequestResult(
      Success: false,
      Error: pe.msg,
      Res: nil
    )
  finally:
    client.close()

# ----------------------------------------------------------------

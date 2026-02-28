import std/httpclient
import std/math
import base
import json

# TYPES ----------------------------------------------------------

type RecordObject* = object
  Key*: string         #json: key
  StartTime*: int64    #json: t1
  StopTime*: int64     #json: t2
  Description*: string #json: ds
  ModifiedTime*: int64 #json: mt
  ServerTime*: float64 #json: st (default: 0.0)

type GetResult* = object
  Success*: bool
  Error*: string
  Records*: seq[RecordObject]

type PutResultRaw* = object of RootObj
  Accepted*: seq[string] #json: accepted
  Failed*: seq[string]   #json: failed
  Errors*: seq[string]   #json: errors

type PutResult* = object of PutResultRaw
  Success*: bool
  Error*: string

type RecordEndpoint* = object
  Helper*: BaseHelper
  Get*: proc(startTime: float, stopTime: float): GetResult
  Put*: proc(items: seq[RecordObject]): PutResult

# ----------------------------------------------------------------
# PRIVATE PROCS --------------------------------------------------

proc toRecordObjectSeq(node: JsonNode): seq[RecordObject] =
  var res: seq[RecordObject] = @[]
  for n in node.elems:
    res.add(RecordObject(
      Key: n["key"].getStr(""),
      StartTime: n["t1"].getInt(0),
      StopTime: n["t2"].getInt(0),
      Description: n["ds"].getStr(""),
      ModifiedTime: n["mt"].getInt(0),
      ServerTime: n["st"].getFloat(0.0)
    ))
  return res


proc toPutResultRaw(node: JsonNode): PutResultRaw =
  var res = PutResultRaw(Accepted: @[], Failed: @[], Errors: @[])

  for accepted in node["accepted"].items:
    res.Accepted.add(accepted.getStr())

  for failed in node["failed"].items:
    res.Failed.add(failed.getStr())

  for errors in node["errors"].items:
    res.Errors.add(errors.getStr())

  return res

# ----------------------------------------------------------------
# PUBLIC PROCS ---------------------------------------------------

proc Get*(rep: var RecordEndpoint, startTime: float, stopTime: float): GetResult =
  var res = rep.Helper.DoGet("/records?timerange=" & $round(startTime, 0) & "-" & $round(stopTime, 0))
  var ro = toRecordObjectSeq(parseJson(res.Res.body()))
  return GetResult(
    Success: res.Success,
    Error: res.Error,
    Records: ro
  )


proc Put*(rep: var RecordEndpoint, items: seq[RecordObject]): PutResult =
  var res = rep.Helper.DoPut("/records", "")
  var ro = toPutResultRaw(parseJson(res.Res.body()))
  return PutResult(
    Success: res.Success,
    Error: res.Error,
    Accepted: ro.Accepted,
    Failed: ro.Failed,
    Errors: ro.Errors
  )

# ----------------------------------------------------------------

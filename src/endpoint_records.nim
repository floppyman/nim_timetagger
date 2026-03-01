import std/httpclient
import std/json
import std/jsonutils
import std/strformat
import base

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

# ----------------------------------------------------------------
# PRIVATE PROCS --------------------------------------------------

proc toRecordObjectSeq(node: JsonNode, doLogging: bool): seq[RecordObject] =
  if doLogging:
    echo "Records / toRecordObjectSeq ------"
    echo "jsonNode:"
    echo node
    echo "----------------------------------"

  var res: seq[RecordObject] = @[]

  for n in node["records"].elems:
    res.add(RecordObject(
      Key: n["key"].getStr(""),
      StartTime: n["t1"].getInt(0),
      StopTime: n["t2"].getInt(0),
      Description: n["ds"].getStr(""),
      ModifiedTime: n["mt"].getInt(0),
      ServerTime: n["st"].getFloat(0.0)
    ))
  return res


proc toPutResultRaw(node: JsonNode, doLogging: bool): PutResultRaw =
  if doLogging:
    echo "Records / toPutResultRaw ------"
    echo "jsonNode:"
    echo node
    echo "-------------------------------"

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

proc Get*(self: var RecordEndpoint, startTime: int64, stopTime: int64): GetResult =
  if self.Helper.DoLogging:
    echo "Records / Get -------"
    echo fmt"startTime: {$startTime}"
    echo fmt"stopTime: {$stopTime}"
    echo "---------------------"
  
  var res = self.Helper.DoGet(fmt"/records?timerange={$startTime}-{$stopTime}")
  
  if res.Success:
    var obj = toRecordObjectSeq(parseJson(res.Res.body()), self.Helper.DoLogging)
    return GetResult(
      Success: res.Success,
      Error: res.Error,
      Records: obj
    )

  return GetResult(
      Success: res.Success,
      Error: res.Error,
      Records: @[]
    )


proc Put*(self: var RecordEndpoint, items: seq[RecordObject]): PutResult =
  if self.Helper.DoLogging:
    echo "Records / Put -------"
    echo fmt"items: {$items}"
    echo "---------------------"

  var res = self.Helper.DoPut("/records", toJson(items).getStr())

  if res.Success:
    var obj = toPutResultRaw(parseJson(res.Res.body()), self.Helper.DoLogging)
    return PutResult(
      Success: res.Success,
      Error: res.Error,
      Accepted: obj.Accepted,
      Failed: obj.Failed,
      Errors: obj.Errors
    )

  return PutResult(
      Success: res.Success,
      Error: res.Error,
      Accepted: @[],
      Failed: @[],
      Errors: @[]
    )

# ----------------------------------------------------------------

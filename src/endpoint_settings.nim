import std/httpclient
import std/json
import std/jsonutils
import std/strformat
import base

# TYPES ----------------------------------------------------------

type SettingObject* = object
  Key*: string         #json: key
  Value*: JsonNode     #json: value
  ModifiedTime*: int64 #json: mt
  ServerTime*: float64 #json: st (default: 0.0)

type GetResult* = object
  Success*: bool
  Error*: string
  Settings*: seq[SettingObject] #json: settings

type PutResultRaw* = object of RootObj
  Accepted*: seq[string] #json: accepted
  Failed*: seq[string]   #json: failed
  Errors*: seq[string]   #json: errors

type PutResult* = object of PutResultRaw
  Success*: bool
  Error*: string

type SettingEndpoint* = object
  Helper*: BaseHelper

# ----------------------------------------------------------------
# PRIVATE PROCS --------------------------------------------------

proc toSettingObjectSeq(node: JsonNode, doLogging: bool): seq[SettingObject] =
  if doLogging:
    echo "Settings / toSettingObjectSeq ------"
    echo node
    echo "------------------------------------"

  var res: seq[SettingObject] = @[]

  for n in node["settings"].elems:
    res.add(SettingObject(
      Key: n["key"].getStr(""),
      ModifiedTime: n["mt"].getInt(0),
      Value: n["value"],
      ServerTime: n["st"].getFloat(0.0)
    ))
  return res


proc toPutResultRaw(node: JsonNode, doLogging: bool): PutResultRaw =
  if doLogging:
    echo "Settings / toPutResultRaw ------"
    echo node
    echo "--------------------------------"

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

proc Get*(self: var SettingEndpoint, startTime: int64, stopTime: int64): GetResult =
  if self.Helper.DoLogging:
    echo "Settings / Get -------"
    echo fmt"startTime: {$startTime}"
    echo fmt"stopTime: {$stopTime}"
    echo "----------------------"

  var res = self.Helper.DoGet("/settings")

  if res.Success:
    var obj = toSettingObjectSeq(parseJson(res.Res.body()), self.Helper.DoLogging)
    return GetResult(
      Success: res.Success,
      Error: res.Error,
      Settings: obj
    )

  return GetResult(
      Success: res.Success,
      Error: res.Error,
      Settings: @[]
    )


proc Put*(self: var SettingEndpoint, items: seq[SettingObject]): PutResult =
  if self.Helper.DoLogging:
    echo "Settings / Put -------"
    echo fmt"items: {$items}"
    echo "----------------------"
  
  var res = self.Helper.DoPut("/settings", toJson(items).getStr())

  if res.Success:
    var ro = toPutResultRaw(parseJson(res.Res.body()), self.Helper.DoLogging)
    return PutResult(
      Success: res.Success,
      Error: res.Error,
      Accepted: ro.Accepted,
      Failed: ro.Failed,
      Errors: ro.Errors
    )

  return PutResult(
      Success: res.Success,
      Error: res.Error,
      Accepted: @[],
      Failed: @[],
      Errors: @[]
    )

# ----------------------------------------------------------------

import std/httpclient
import std/json
import std/strformat
import base
import endpoint_records as epRec
import endpoint_settings as epSet

# TYPES ----------------------------------------------------------

type UpdateObject* = object
  ServerTime*: float64                #json: server_time
  Reset*: bool                        #json: reset (default: 0)
  Records*: seq[epRec.RecordObject]   #json: records
  Settings*: seq[epSet.SettingObject] #json: settings

type GetResult* = object
  Success*: bool
  Error*: string
  Updates*: UpdateObject #json: settings

type UpdateEndpoint* = object
  Helper*: BaseHelper

# ----------------------------------------------------------------
# PRIVATE PROCS --------------------------------------------------

proc toUpdateObject(node: JsonNode, doLogging: bool): UpdateObject =
  if doLogging:
    echo "Updates / toUpdateObject ------"
    echo "jsonNode:"
    echo node
    echo "-------------------------------"

  var res: UpdateObject = UpdateObject()

  res.ServerTime = node["server_time"].getFloat(0.0)
  res.Reset = node["reset"].getBool(false)

  for n in node["records"].elems:
    res.Records.add(RecordObject(
      Key: n["key"].getStr(""),
      StartTime: n["t1"].getInt(0),
      StopTime: n["t2"].getInt(0),
      Description: n["ds"].getStr(""),
      ModifiedTime: n["mt"].getInt(0),
      ServerTime: n["st"].getFloat(0.0)
    ))

  for n in node["settings"].elems:
    res.Settings.add(SettingObject(
      Key: n["key"].getStr(""),
      ModifiedTime: n["mt"].getInt(0),
      Value: n["value"],
      ServerTime: n["st"].getFloat(0.0)
    ))
  
  return res

# ----------------------------------------------------------------
# PUBLIC PROCS ---------------------------------------------------

proc Get*(self: var UpdateEndpoint, since: int64): GetResult =
  if self.Helper.DoLogging:
    echo "Updates / Get -------"
    echo fmt"since: {$since}"
    echo "---------------------"
  
  var res = self.Helper.DoGet(fmt"/updates?since={$since}")

  if res.Success:
    var obj = toUpdateObject(parseJson(res.Res.body()), self.Helper.DoLogging)
    return GetResult(
      Success: res.Success,
      Error: res.Error,
      Updates: obj
    )

  return GetResult(
      Success: res.Success,
      Error: res.Error,
      Updates: UpdateObject()
    )

# ----------------------------------------------------------------

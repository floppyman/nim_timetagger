import std/httpclient
import std/json
import base

# TYPES ----------------------------------------------------------

type VersionObject* = object
  Version*: string #json: version

type GetResult* = object
  Success*: bool
  Error*: string
  Version*: VersionObject

type VersionEndpoint* = object
  Helper*: BaseHelper

# ----------------------------------------------------------------
# PRIVATE PROCS --------------------------------------------------

proc toVersionObject(node: JsonNode, doLogging: bool): VersionObject =
  if doLogging:
    echo "Version / toVersionObject ------"
    echo node
    echo "--------------------------------"

  var res: VersionObject = VersionObject()

  res.Version = node["version"].getStr("0.0.0")

  return res

# ----------------------------------------------------------------
# PUBLIC PROCS ---------------------------------------------------

proc Get*(self: var VersionEndpoint): GetResult =
  if self.Helper.DoLogging:
    echo "Version / Get -------"
    echo "---------------------"
  
  var res = self.Helper.DoGet("/version")

  if res.Success:
    var obj = toVersionObject(parseJson(res.Res.body()), self.Helper.DoLogging)
    return GetResult(
      Success: res.Success,
      Error: res.Error,
      Version: obj
    )

  return GetResult(
      Success: res.Success,
      Error: res.Error,
      Version: VersionObject()
    )

# ----------------------------------------------------------------

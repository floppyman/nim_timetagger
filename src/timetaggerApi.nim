import std/strformat
import base
import endpoint_records as epRec
import endpoint_settings as epSet
import endpoint_update as epUpd
import endpoint_version as epVer

# TYPES ----------------------------------------------------------

type TimeTaggerApiClient* = object
  Records*: epRec.RecordEndpoint
  Settings*: epSet.SettingEndpoint
  Updates*: epUpd.UpdateEndpoint
  Version*: epVer.VersionEndpoint

type TimeTaggerApiOptions* = object
  Url*: string
  Token*: string
  Timeout*: int = 20

# ----------------------------------------------------------------
# PROCS ----------------------------------------------------------

proc NewClient*(url: string, token: string, timeout: int = 20, doLogging: bool = false): TimeTaggerApiClient =
  if doLogging:
    echo "NewClient -------"
    echo fmt"url: {url}"
    echo fmt"token: {token}"
    echo fmt"timeout: {timeout}"
    echo fmt"doLogging: {doLogging}"
    echo "-----------------"

  var helper = BaseHelper(
    Url: url, 
    Token: token, 
    Timeout: timeout,
    DoLogging: doLogging
  )
  
  return TimeTaggerApiClient(
    Records: epRec.RecordEndpoint(Helper: helper),
    Settings: epSet.SettingEndpoint(Helper: helper),
    Updates: epUpd.UpdateEndpoint(Helper: helper),
    Version: epVer.VersionEndpoint(Helper: helper)
  )

# ----------------------------------------------------------------
# EXAMPLE

# import timetaggerApi as api
# import endpoint_records as apiRec

# var x = api.NewClient("", "")

# var g = x.Records.Get(0, 0)
# echo g.Success

# var p = x.Records.Put(@[apiRec.RecordObject(Key: "")])
# echo p.Success

# ----------------------------------------------------------------
import base
import endpoint_records as epRec
import endpoint_settings as epSet
import endpoint_update as epUpd

# TYPES ----------------------------------------------------------

type TimeTaggerApiClient* = object
  Records*: epRec.RecordEndpoint
  Settings*: epSet.SettingEndpoint
  Updates*: epUpd.UpdateEndpoint

type TimeTaggerApiOptions* = object
  Url*: string
  Token*: string
  Timeout*: int = 20

# ----------------------------------------------------------------
# PROCS ----------------------------------------------------------

proc NewClient*(url: string, token: string, timeout: int = 20): TimeTaggerApiClient =
  var helper = BaseHelper(
    Url: url, 
    Token: token, 
    Timeout: timeout
  )
  
  return TimeTaggerApiClient(
    Records: epRec.RecordEndpoint(Helper: helper),
    Settings: epSet.SettingEndpoint(Helper: helper),
    Updates: epUpd.UpdateEndpoint(Helper: helper)
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
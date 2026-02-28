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
  Timeout*: int = -1

# ----------------------------------------------------------------
# PROCS ----------------------------------------------------------

proc New*(options: TimeTaggerApiOptions): TimeTaggerApiClient =
  var helper = BaseHelper(Url: options.Url, Token: options.Token, Timeout: options.Timeout)
  return TimeTaggerApiClient(
    Records: epRec.RecordEndpoint(Helper: helper),
    Settings: epSet.SettingEndpoint(Helper: helper),
    Updates: epUpd.UpdateEndpoint(Helper: helper)
  )

# ----------------------------------------------------------------

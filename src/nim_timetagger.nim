import timetagger_api/api_client as api
import timetagger_api/endpoint_records as apiRec

# TYPES ----------------------------------------------------------

# ----------------------------------------------------------------
# PROCS ----------------------------------------------------------

proc NewClient*(url: string, token: string): TimeTaggerApiClient =
  return api.New(TimeTaggerApiOptions(Url: url, Token: token))

# ----------------------------------------------------------------
# EXAMPLE

# var x = NewClient("", "")

# var g = x.Records.Get(0, 0)
# echo g.Success

# var p = x.Records.Put(@[apiRec.RecordObject(Key: "")])
# echo p.Success

# ----------------------------------------------------------------
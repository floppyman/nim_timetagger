import timetagger_api/api_client

# TYPES ----------------------------------------------------------

# ----------------------------------------------------------------
# PROCS ----------------------------------------------------------

proc NewClient*(url: string, token: string, timeout: int = 20): TimeTaggerApiClient =
  return New(TimeTaggerApiOptions(Url: url, Token: token))

# ----------------------------------------------------------------
# EXAMPLE

# import nim_timetagger as ntt
# import timetagger_api/endpoint_records as apiRec

# var x = ntt.NewClient("", "")

# var g = x.Records.Get(0, 0)
# echo g.Success

# var p = x.Records.Put(@[apiRec.RecordObject(Key: "")])
# echo p.Success

# ----------------------------------------------------------------
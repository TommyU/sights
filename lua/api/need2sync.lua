local video_utils = require("libs.video_utils")

local args = ngx.req.get_uri_args()
local hash = args.id

video_utils:mark_video_need2sync(id)

ngx.say("done")
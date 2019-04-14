local video_utils = require("libs.video_utils")

local args = ngx.req.get_uri_args()

video_utils:mark_video_need2sync(args.id)

ngx.say("done")
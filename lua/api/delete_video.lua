---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by tommy.
--- DateTime: 2018/6/24 下午12:38
---

local video_utils = require("libs.video_utils")

local args = ngx.req.get_uri_args()
local hash = args.hash

video_utils:delete_video(hash)

ngx.say("done")
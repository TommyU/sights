---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by tommy.
--- DateTime: 2018/6/16 下午4:20
---
local constants = require("libs.constants")
local response = require("libs.response")

local args = ngx.req.get_uri_args()

local youtube_url = args.video_url
if not youtube_url then
    response.json_response({ msg = "arg video_url" }, 400)
end


-- check status in redis
local redis_client = require("libs.redis")
local cjson = require("cjson")
local info = redis_client:get(youtube_url)
if info then
    local json_info = cjson.decode(info)
    if json_info.video_path then
        response.json_response({ status = constants.VIDEO_DOWNLOADED })
    else
        response.json_response({ status = constants.VIDEO_DOWNLOADING })
    end
else
    response.json_response({ status = constants.VIDEO_NOT_INITED })
end

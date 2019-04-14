local video_utils = require("libs.video_utils")
local response = require("libs.response")

local args = ngx.req.get_uri_args()
local video_id = args.id
local secret = args.s
if secret == '2c81697af5651a4e4be730d02d6b49e4' then
	video_utils:mark_job_synced(video_id)
end
response.json_response({})

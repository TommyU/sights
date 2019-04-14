-- this api is to display video list to sync to home theater

local video_utils = require("libs.video_utils")
local response = require("libs.response")

local list = video_utils:get_list2sync()
local ret  = {}
for _, line in ipairs(list) do
    ret[#ret+1] = line
end
response.json_response(ret)

---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by tommy.
--- DateTime: 2018/6/16 下午12:10
---

local _M = {}
local cjson = require("cjson")

function _M.json_response(table_obj, status)
    ngx.header.content_type="application/json;charset=utf-8"

    ngx.say(cjson.encode(table_obj))
    if not status then
        status=200
    end
    ngx.exit(status)
end

return _M
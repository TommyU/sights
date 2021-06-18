---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by tommy.
--- DateTime: 2021/6/18 4:38 下午
---
local ngx = ngx
local google_search = require("libs.google_search")

 local ret, err = google_search.proxy_request(true, "www.google.com", 443)
if err ~= nil then
    ngx.status = 500
    ngx.print("server error: " .. err)
    ngx.exit(ngx.HTTP_OK)  -- https://segmentfault.com/a/1190000004534300
end
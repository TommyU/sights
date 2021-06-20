---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by tommy.
--- DateTime: 2018/6/16 下午12:15
---
local require = require
local ngx = ngx
local ngx_req = ngx.req
local ngx_var = ngx.var
local io_open = io.open
local tostring = tostring
local string_upper = string.upper
local setmetatable = setmetatable
local http = require("resty.http")
local cjson = require("cjson")

local _M = {}
_M.__index = _M

function _M:new(keyword)
    return setmetatable({ keyword = keyword, start_index = 1 }, self)
end

function _M:search_youtube(start_index)
    local httpc = http.new()
    local google_url = "https://www.googleapis.com/customsearch/v1?cx=011413660507430971103%3Aolhbaywiu58&key=AIzaSyA0CD1m7GslZH8WUwNP0UZYcfgvx-pt1dk"
    if start_index then
        self.start_index = start_index
    end

    local q = ngx.encode_args({ q = self.keyword, start = self.start_index })
    local res, err = httpc:request_uri(
            google_url .. "&" .. q,
            { ssl_verify = false }
    )

    if err ~= nil then
        ngx.log(ngx.ERR, "oopsssssss==> " .. err)
        return nil
    else
        ngx.log(ngx.DEBUG, res.body)
        return self:format_google_search_result(res.body)
    end
end

local mutable = {
    PUT = true,
    POST = true,
    DELETE = true,
    PATCH = true,
}

local function might_have_body(http_method)
    return mutable[string_upper(http_method)]
end

local function get_request_body(http_method)
    if not might_have_body(http_method) then
        return nil
    end
    ngx_req.read_body()
    local body = ngx_req.get_body_data()
    if not body then
        local datafile = ngx_req.get_body_file()
        if datafile then
            local fh, err = io_open(datafile, "r")
            if not fh then
                ngx.log(ngx.Err, "failed to open body file" .. tostring(datafile) ..  ", err is %s" .. tostring(err))
            else
                fh:seek("set")
                body = fh:read("*a")
                fh:close()
            end
        else
            --log.debug("no data in request.body")
        end
    end
    return body
end

function _M.proxy_request(is_https, host, port)
    -- ||====  proxy request =====||
    local _httpc = http.new()

    -- connect & handshake
    _httpc:set_timeouts(3000, 5000, 10000)
    local _, err = _httpc:connect(host, port)
    if err then
        ngx.log(ngx.ERR, "connect to " .. host .. "  error:" .. err)
        _httpc:close()
        return nil, err
    end
    if is_https then
        local _, err = _httpc:ssl_handshake(nil, host)
        if err then
            _httpc:close()
            ngx.log(ngx.ERR, "ssl handshake fail:  " .. host .. " err:" .. err)
            return nil, err
        end
    end

    --  prepare args & send request
    local method = ngx.req.get_method()
    local body = get_request_body(method)
    local path = ngx_var.uri
    local uri_args, _ = ngx_req.get_uri_args(1000)
    local headers, _ = ngx_req.get_headers()
    headers['host'] = host
    ngx.log(ngx.ERR, "====" .. cjson.encode(headers))


    local res, err1 = _httpc:request({
        method = method,
        path = path,
        query = uri_args,
        body = body,
        headers = headers,
    })

    if err1 ~= nil then
        ngx.log(ngx.ERR, "error send request:" .. err1)
        _httpc:close()
        return nil, err1
    end

    local res_body, err2 = res:read_body()  -- TODO: big body
    if err2 ~= nil then
        ngx.log(ngx.ERR, "error read response body:" .. err2)
        _httpc:close()
        return nil, err2
    end

    if err1 == nil and err2 == nil then
        _httpc:set_keepalive(60000, 10)
    else
        _httpc:close()
    end

    -- ||====  output =====||
    -- 1. status
    if res ~= ngx.null and res.status ~= nil and res.status > 0 then
        ngx.status = res.status
    else
        ngx.status = ngx.HTTP_OK
    end

    -- 2. headers
    if res ~= ngx.null and res.headers ~= nil then
        for k, v in pairs(res.headers) do
            ngx.header[k] = v
        end
    end
    if not ngx.header['Content-Type'] then
        ngx.header['Content-Type'] = 'text/html'
    end

    -- 3. body
    ngx.print(res_body)

    ngx.exit(ngx.HTTP_OK)  -- https://segmentfault.com/a/1190000004534300

    local response = {}
    response.body = res_body
    response.headers = res.headers
    response.status = res.status
    return response, nil
end

function _M:format_google_search_result(json_string)
    local formated_json = { total = 0, items = {} }

    local json_result = cjson.decode(json_string)

    formated_json.total = json_result.searchInformation.totalResults
    ngx.log(ngx.DEBUG, "total results: " .. formated_json.total)
    for _, item in ipairs(json_result.items) do
        formated_json.items[#formated_json.items + 1] = {
            title = item.title,
            link = item.link,
            htmlTitle = item.htmlTitle
        }
    end
    return formated_json
end

return _M

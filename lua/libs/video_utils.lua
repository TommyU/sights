---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by tommy.
--- DateTime: 2018/6/16 下午7:07
---
local constants = require("libs.constants")
local redis_client = require("libs.redis")
local mysql_client = require("libs.db")
local cjson = require("cjson")
local EXPIRE_SECONDS = 3600

local _M = {}
_M.__index = _M

local function exists(name)
    local f = io.open(name, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

local function get_file_size(file_name)
    local f = io.open(file_name, "r")
    if f ~= nil then
        local size = f:seek('end')
        io.close(f)
        return size
    else
        return 0
    end
end

local function update_redis_cache(video_url_hash, video_path)
    local downloading_info = cjson.encode({ video_path = video_path })
    redis_client:set(video_url_hash, downloading_info, EXPIRE_SECONDS)
end

local function get_stored_path(video_url_hash)
    return '/root/sights/statics/videos/' .. video_url_hash .. '.mp4'
end

local function add2db(keyword, video_url, video_name)
    local sql = [[insert into sights.video_tab(ctime, keyword, youtube_url, youtube_url_hash, video_name, last_downloaded_time, stored_path, video_size)
    values(%d, %s, %s, %s, %s, %d, %s, %d)]]

    local video_url_hash = constants:get_video_hash(video_url)
    local stored_path = get_stored_path(video_url_hash)
    local video_size = 0

    video_url_hash = ndk.set_var.set_quote_sql_str(video_url_hash)
    stored_path = ndk.set_var.set_quote_sql_str(stored_path)
    keyword = ndk.set_var.set_quote_sql_str(keyword)
    video_url = ndk.set_var.set_quote_sql_str(video_url)
    video_name = ndk.set_var.set_quote_sql_str(video_name)

    sql = string.format(sql, ngx.time(), keyword, video_url, video_url_hash, video_name, ngx.time(), stored_path, video_size)
    local res = assert(mysql_client:query(sql))
    return res
end

local function update_video_size(id, real_size)
    local sql = [[update sights.video_tab set video_size=%d where id=%d]]

    ngx.log(ngx.DEBUG, sql)
    sql = string.format(sql, real_size, id)
    local res = assert(mysql_client:query(sql))
    return res
end

local function mark_download2db(youtube_url)
    -- meant for duplicated downloading(in case file deleted already)
    local sql = [[update sights.video_tab set last_downloaded_time = %d, stored_path='%s', downloaded_times=downloaded_times+1 where youtube_url_hash='%s' ]]
    local video_url_hash = constants:get_video_hash(youtube_url)
    local params = { ngx.time(), get_stored_path(video_url_hash), video_url_hash }
    local res = assert(mysql_client:query(sql, params))
    return res
end

local function mark_deleted2db(youtube_url)
    -- in case disk is full, some files will get deleted by cron jobs
    local sql = [[update sights.video_tab set deleted_time = %d, is_deleted=1 where youtube_url_hash='%s' ]]
    local video_url_hash = constants:get_video_hash(youtube_url)
    local params = { ngx.time(), video_url_hash }
    local res = assert(mysql_client:query(sql, params))
    return res
end

function _M:download_from_youtube(video_url, keyword, video_name)
    ngx.log(ngx.DEBUG, "------start to download video: " .. video_url)
    local video_url_hash = constants:get_video_hash(video_url)
    local local_file_name = get_stored_path(video_url_hash)

    if exists(local_file_name) then
        update_redis_cache(video_url_hash, local_file_name)
    else
        update_redis_cache(video_url_hash, nil)
        os.execute("youtube-dl -f mp4  -o " .. local_file_name .. " " .. video_url)
        update_redis_cache(video_url_hash, local_file_name)
        add2db(keyword, video_url, video_name)
    end
end

function _M:get_downloaded_list()
    local sql = [[select id, video_name, video_size, ctime, last_downloaded_time, downloaded_times, keyword, youtube_url_hash  as hash, is_deleted, deleted_time from sights.video_tab where is_deleted=0 ]]
    local res = assert(mysql_client:query(sql))
    return res
end

function _M:update_all_video_sizes()
    ngx.log(ngx.DEBUG, 'all sizes updating triggered...')
    local sql = [[select id,  youtube_url_hash  as hash from sights.video_tab where  video_size is null or video_size=0]]
    local res = assert(mysql_client:query(sql))
    for _, line in ipairs(res) do
        ngx.log(ngx.DEBUG, 'processing size for ' .. line.id)
        local fn = get_stored_path(line.hash)
        local real_size = get_file_size(fn)
        update_video_size(line.id, real_size)
    end
    return res
end

function _M:delete_video(video_url_hash)
    ngx.log(ngx.DEBUG, 'video deleting triggered...')
    video_url_hash = ndk.set_var.set_quote_sql_str(video_url_hash)
    local sql = string.format([[update sights.video_tab set is_deleted=1 where  youtube_url_hash=%s]], video_url_hash)
    assert(mysql_client:query(sql))
    local stored_path = get_stored_path(video_url_hash)
    redis_client:delete(video_url_hash)
    os.execute("rm " .. stored_path)
end

return _M

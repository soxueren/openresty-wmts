--author:medcl,m@medcl.net,http://log.medcl.net
function exit_with_code(code)
--    ngx.say(code)
    ngx.exit(code)
    return
end

function req_orig_file(wmts_url)
    local http = require"resty.http"
    local hc = http:new()
    local ok, code, headers, status, body = hc:request{
        url = wmts_url,
        timeout = 3000,
    }

    if code == 301 or code == 302 then
       wmts_url = string.match(body,'"(.+)"')
       ok, code, headers, status, body = hc:request{
        url = wmts_url,
        timeout = 3000,
       }
    end

    if code ~= 200 then
       return exit_with_code(404)
    else
        if body == nil then
            return exit_with_code(404)
        else
            if (body..'a') == 'a' then
                return exit_with_code(404)
            else
                ngx.say(body)
                ngx.flush(true)
		exit_with_code(200)
                return
            end
        end
    end
end

function req_volume_server()
-- TODO,get from weedfs,curl http://localhost:9333/dir/lookup?volumeId=3
end

function process_wmts(l,c,x,y,z,wmts_url)
    return req_orig_file(wmts_url)	
end

function process_sayurl(wmts_url)
    ngx.say(wmts_url)
    ngx.flush(true)
	return
end

function process_test(test_url)
    return req_orig_file(test_url)	
end

local l = ngx.var.arg_l or "na";
local c = ngx.var.arg_c or "na";
local x = ngx.var.arg_x or "na";
local y = ngx.var.arg_y or "na";
local z = ngx.var.arg_z  or "na";

local process_type = ngx.var.arg_type or "na";
local file_url = ngx.var.local_img_fs_root .. c .. "/" .. l .."/" .. z .. "_" .. x .. "_" .. y .. ".png"
local wmts_url = ngx.var.weed_img_root_url .. "/foo/" .. l .. "_" .. c .. "_" .. z .. "_" .. x .. "_" .. y .. ".png"
local test_url = ngx.var.weed_img_root_url .. "/foo/" .. "well.png"

if ngx.var.arg_z == nil or ngx.var.arg_x == nil or ngx.var.arg_y== nil then
    return exit_with_code(400)
end

--enterpoint
if(process_type == "wmts")then
    process_wmts(l,c,x,y,z,wmts_url)	
elseif(process_type == "test")then	
    process_test(test_url)
end

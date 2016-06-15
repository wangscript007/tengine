# vim:set ft= ts=4 sw=4 et fdm=marker:
use lib 'lib';
use Test::Nginx::Socket;

#worker_connections(1014);
#master_on();
#workers(2);
log_level('warn');

repeat_each(2);
#repeat_each(1);

plan tests => repeat_each() * (blocks() * 2 + 7);

no_root_location();

#no_shuffle();
#no_diff();
no_long_string();
run_tests();

__DATA__

=== TEST 1: sanity
--- config
    location /lua {
        content_by_lua '
            local args = ngx.req.get_uri_args()
            local keys = {}
            for key, val in pairs(args) do
                table.insert(keys, key)
            end

            table.sort(keys)
            for i, key in ipairs(keys) do
                ngx.say(key, " = ", args[key])
            end
        ';
    }
--- request
GET /lua?a=3&b=4&c
--- response_body
a = 3
b = 4
c = true



=== TEST 2: args take no value
--- config
    location /lua {
        content_by_lua '
            local args = ngx.req.get_uri_args()
            local keys = {}
            for key, val in pairs(args) do
                table.insert(keys, key)
            end

            table.sort(keys)
            for i, key in ipairs(keys) do
                ngx.say(key, " = ", args[key])
            end
        ';
    }
--- request
GET /lua?foo&baz=&bar=42
--- response_body
bar = 42
baz = 
foo = true



=== TEST 3: arg key and value escaped
--- config
    location /lua {
        content_by_lua '
            local args = ngx.req.get_uri_args()
            local keys = {}
            for key, val in pairs(args) do
                table.insert(keys, key)
            end

            table.sort(keys)
            for i, key in ipairs(keys) do
                ngx.say(key, " = ", args[key])
            end

            ngx.say("again...")

            args = ngx.req.get_uri_args()
            keys = {}
            for key, val in pairs(args) do
                table.insert(keys, key)
            end

            table.sort(keys)
            for i, key in ipairs(keys) do
                ngx.say(key, " = ", args[key])
            end
        ';
    }
--- request
GET /lua?%3d&b%20r=4%61+2
--- response_body
= = true
b r = 4a 2
again...
= = true
b r = 4a 2



=== TEST 4: empty
--- config
    location /t {
        content_by_lua '
            local args = ngx.req.get_uri_args()
            local keys = {}
            for key, val in pairs(args) do
                table.insert(keys, key)
            end

            table.sort(keys)
            for i, key in ipairs(keys) do
                ngx.say(key, " = ", args[key])
            end

            ngx.say("done")
        ';
    }
--- request
GET /t
--- response_body
done



=== TEST 5: empty arg, but with = and &
--- config
    location /lua {
        content_by_lua '
            local args = ngx.req.get_uri_args()
            local keys = {}
            for key, val in pairs(args) do
                table.insert(keys, key)
            end

            table.sort(keys)
            for i, key in ipairs(keys) do
                ngx.say(key, " = ", args[key])
            end

            ngx.say("done")
        ';
    }
--- request
GET /lua?=&&
--- response_body
done



=== TEST 6: multi-value keys
--- config
    location /lua {
        content_by_lua '
            local args = ngx.req.get_uri_args()
            local keys = {}
            for key, val in pairs(args) do
                table.insert(keys, key)
            end

            table.sort(keys)
            for i, key in ipairs(keys) do
                local val = args[key]
                if type(val) == "table" then
                    ngx.say(key, " = [", table.concat(val, ", "), "]")
                else
                    ngx.say(key, " = ", val)
                end
            end

            ngx.say("done")
        ';
    }
--- request
GET /lua?foo=32&foo==&foo=baz
--- response_body
foo = [32, =, baz]
done



=== TEST 7: multi-value keys
--- config
    location /lua {
        content_by_lua '
            local args = ngx.req.get_uri_args()
            local keys = {}
            for key, val in pairs(args) do
                table.insert(keys, key)
            end

            table.sort(keys)
            for i, key in ipairs(keys) do
                local val = args[key]
                if type(val) == "table" then
                    ngx.say(key, " = [", table.concat(val, ", "), "]")
                else
                    ngx.say(key, " = ", val)
                end
            end

            ngx.say("done")
        ';
    }
--- request
GET /lua?foo=32&foo==&bar=baz
--- response_body
bar = baz
foo = [32, =]
done



=== TEST 8: empty arg
--- config
    location /lua {
        content_by_lua '
            local args = ngx.req.get_uri_args()
            local keys = {}
            -- ngx.say(args)
            for key, val in pairs(args) do
                table.insert(keys, key)
            end

            table.sort(keys)
            for i, key in ipairs(keys) do
                ngx.say(key, " = ", args[key])
            end

            ngx.say("done")
        ';
    }
--- request
GET /lua?&=
--- response_body
done



=== TEST 9: = in value
--- config
    location /lua {
        content_by_lua '
            local args = ngx.req.get_uri_args()
            local keys = {}
            -- ngx.say(args)
            for key, val in pairs(args) do
                table.insert(keys, key)
            end

            table.sort(keys)
            for i, key in ipairs(keys) do
                ngx.say(key, " = ", args[key])
            end

            ngx.say("done")
        ';
    }
--- request
GET /lua?foo===
--- response_body
foo = ==
done



=== TEST 10: empty key, but non-emtpy values
--- config
    location /lua {
        content_by_lua '
            local args = ngx.req.get_uri_args()
            local keys = {}
            for key, val in pairs(args) do
                table.insert(keys, key)
            end

            table.sort(keys)
            for i, key in ipairs(keys) do
                ngx.say(key, " = ", args[key])
            end

            ngx.say("done")
        ';
    }
--- request
GET /lua?=hello&=world
--- response_body
done



=== TEST 11: updating args with $args
--- config
    location /lua {
        content_by_lua '
            local args = ngx.req.get_uri_args()
            local keys = {}
            for key, val in pairs(args) do
                table.insert(keys, key)
            end

            table.sort(keys)
            for i, key in ipairs(keys) do
                ngx.say(key, " = ", args[key])
            end

            ngx.say("updating args...")

            ngx.var.args = "a=3&b=4"

            local args = ngx.req.get_uri_args()
            local keys = {}
            for key, val in pairs(args) do
                table.insert(keys, key)
            end

            table.sort(keys)
            for i, key in ipairs(keys) do
                ngx.say(key, " = ", args[key])
            end

            ngx.say("done")
        ';
    }
--- request
GET /lua?foo=bar
--- response_body
foo = bar
updating args...
a = 3
b = 4
done



=== TEST 12: rewrite uri and args
--- config
    location /bar {
        echo $query_string;
    }
    location /foo {
        #set $args 'hello';
        rewrite_by_lua '
            ngx.req.set_uri_args("hello")
            ngx.req.set_uri("/bar", true);
        ';
        proxy_pass http://agentzh.org:12345;
    }
--- request
    GET /foo?world
--- response_body
hello



=== TEST 13: rewrite args (not break cycle by default)
--- config
    location /bar {
        echo "bar: $uri?$args";
    }
    location /foo {
        #set $args 'hello';
        rewrite_by_lua '
            ngx.req.set_uri_args("hello")
            ngx.req.set_uri("/bar", true)
        ';
        echo "foo: $uri?$args";
    }
--- request
    GET /foo?world
--- response_body
bar: /bar?hello



=== TEST 14: rewrite (not break cycle explicitly)
--- config
    location /bar {
        echo "bar: $uri?$args";
    }
    location /foo {
        #set $args 'hello';
        rewrite_by_lua '
            ngx.req.set_uri_args("hello")
            ngx.req.set_uri("/bar", true)
        ';
        echo "foo: $uri?$args";
    }
--- request
    GET /foo?world
--- response_body
bar: /bar?hello



=== TEST 15: rewrite (break cycle explicitly)
--- config
    location /bar {
        echo "bar: $uri?$args";
    }
    location /foo {
        #set $args 'hello';
        rewrite_by_lua '
            ngx.req.set_uri("/bar")
            ngx.req.set_uri_args("hello")
        ';
        echo "foo: $uri?$args";
    }
--- request
    GET /foo?world
--- response_body
foo: /bar?hello



=== TEST 16: rewrite uri (zero-length)
--- config
    location /foo {
        #set $args 'hello';
        rewrite_by_lua '
            local res, err = pcall(ngx.req.set_uri, "")
            ngx.say("err: ", err)
        ';
        echo "foo: $uri?$args";
    }
--- request
    GET /foo?world
--- response_body
err: attempt to use zero-length uri
foo: /foo?world



=== TEST 17: rewrite uri and args
--- config
    location /bar {
        echo $server_protocol $query_string;
    }
    location /foo {
        #rewrite ^ /bar?hello? break;
        rewrite_by_lua '
            ngx.req.set_uri_args("hello")
            ngx.req.set_uri("/bar")
        ';
        proxy_pass http://127.0.0.1:$TEST_NGINX_SERVER_PORT;
    }
--- request
    GET /foo?world
--- response_body
HTTP/1.0 hello



=== TEST 18: rewrite uri and args (table args)
--- config
    location /bar {
        echo $server_protocol $query_string;
    }
    location /foo {
        #rewrite ^ /bar?hello? break;
        rewrite_by_lua '
            ngx.req.set_uri("/bar")
            ngx.req.set_uri_args({["ca t"] = "%"})
        ';
        proxy_pass http://127.0.0.1:$TEST_NGINX_SERVER_PORT;
    }
--- request
    GET /foo?world
--- response_body
HTTP/1.0 ca%20t=%25



=== TEST 19: rewrite uri and args (never returns)
--- config
    location /bar {
        echo $query_string;
    }
    location /foo {
        #set $args 'hello';
        rewrite_by_lua '
            ngx.req.set_uri_args("hello")
            ngx.req.set_uri("/bar", true);
            ngx.exit(503)
        ';
        proxy_pass http://agentzh.org:12345;
    }
--- request
    GET /foo?world
--- response_body
hello



=== TEST 20: ngx.req.set_uri with jump not allowed in access phase
--- config
    location /bar {
        echo $query_string;
    }
    location /foo {
        #set $args 'hello';
        set $err '';
        access_by_lua '
            res, err = pcall(ngx.req.set_uri, "/bar", true);
            ngx.var.err = err
        ';
        echo "err: $err";
    }
--- request
    GET /foo?world
--- response_body
err: API disabled in the context of access_by_lua*



=== TEST 21: ngx.req.set_uri without jump allowed in access phase
--- config
    location /bar {
        echo $query_string;
    }
    location /foo {
        #set $args 'hello';
        set $err '';
        access_by_lua '
            ngx.req.set_uri("/bar")
        ';
        echo "uri: $uri";
    }
--- request
    GET /foo?world
--- response_body
uri: /bar



=== TEST 22: ngx.req.set_uri with jump not allowed in content phase
--- config
    location /bar {
        echo $query_string;
    }
    location /foo {
        #set $args 'hello';
        content_by_lua '
            res, err = pcall(ngx.req.set_uri, "/bar", true);
            ngx.say("err: ", err)
        ';
    }
--- request
    GET /foo?world
--- response_body
err: API disabled in the context of content_by_lua*



=== TEST 23: ngx.req.set_uri without jump allowed in content phase
--- config
    location /bar {
        echo $query_string;
    }
    location /foo {
        #set $args 'hello';
        set $err '';
        content_by_lua '
            ngx.req.set_uri("/bar")
            ngx.say("uri: ", ngx.var.uri)
        ';
    }
--- request
    GET /foo?world
--- response_body
uri: /bar



=== TEST 24: ngx.req.set_uri with jump not allowed in set_by_lua
--- config
    location /bar {
        echo $query_string;
    }
    location /foo {
        #set $args 'hello';
        set_by_lua $err '
            res, err = pcall(ngx.req.set_uri, "/bar", true);
            return err
        ';
        echo "err: $err";
    }
--- request
    GET /foo?world
--- response_body
err: API disabled in the context of set_by_lua*



=== TEST 25: ngx.encode_args (sanity)
--- config
    location /lua {
        set_by_lua $args_str '
            local t = {a = "bar", b = "foo"}
            return ngx.encode_args(t)
        ';
        echo $args_str;
    }
--- request
GET /lua
--- response_body
a=bar&b=foo



=== TEST 26: ngx.encode_args (empty table)
--- config
    location /lua {
        content_by_lua '
            local t = {a = nil}
            ngx.say("args:" .. ngx.encode_args(t))
        ';
    }
--- request
GET /lua
--- response_body
args:



=== TEST 27: ngx.encode_args (value is table)
--- config
    location /lua {
        content_by_lua '
            local t = {a = {9, 2}, b = 3}
            ngx.say("args:" .. ngx.encode_args(t))
        ';
    }
--- request
GET /lua
--- response_body_like
^args:(?:a=9&a=2&b=3|b=3&a=9&a=2)$



=== TEST 28: ngx.encode_args (boolean values)
--- config
    location /lua {
        content_by_lua '
            local t = {a = true, foo = 3}
            ngx.say("args: " .. ngx.encode_args(t))
        ';
    }
--- request
GET /lua
--- response_body_like
^args: (?:a&foo=3|foo=3&a)$



=== TEST 29: ngx.encode_args (boolean values, false)
--- config
    location /lua {
        content_by_lua '
            local t = {a = false, foo = 3}
            ngx.say("args: " .. ngx.encode_args(t))
        ';
    }
--- request
GET /lua
--- response_body
args: foo=3



=== TEST 30: ngx.encode_args (bad table value)
--- config
    location /lua {
        content_by_lua '
            local t = {bar = {32, true}, foo = 3}
            rc, err = pcall(ngx.encode_args, t)
            ngx.say("rc: ", rc, ", err: ", err)
        ';
    }
--- request
GET /lua
--- response_body
rc: false, err: attempt to use boolean as query arg value



=== TEST 31: ngx.encode_args (bad user data value)
--- http_config
    lua_shared_dict dogs 1m;
--- config
    location /lua {
        content_by_lua '
            local t = {bar = ngx.shared.dogs, foo = 3}
            rc, err = pcall(ngx.encode_args, t)
            ngx.say("rc: ", rc, ", err: ", err)
        ';
    }
--- request
GET /lua
--- response_body
rc: false, err: attempt to use userdata as query arg value



=== TEST 32: ngx.encode_args (empty table)
--- config
    location /lua {
        content_by_lua '
            local t = {}
            ngx.say("args: ", ngx.encode_args(t))
        ';
    }
--- request
GET /lua
--- response_body
args: 



=== TEST 33: ngx.encode_args (bad arg)
--- config
    location /lua {
        content_by_lua '
            local rc, err = pcall(ngx.encode_args, true)
            ngx.say("rc: ", rc, ", err: ", err)
        ';
    }
--- request
GET /lua
--- response_body
rc: false, err: bad argument #1 to '?' (table expected, got boolean)



=== TEST 34: max args (limited after normal key=value)
--- config
    location /lua {
        content_by_lua '
            local args = ngx.req.get_uri_args(2)
            local keys = {}
            for key, val in pairs(args) do
                table.insert(keys, key)
            end

            table.sort(keys)
            for i, key in ipairs(keys) do
                ngx.say(key, " = ", args[key])
            end
        ';
    }
--- request
GET /lua?foo=3&bar=4&baz=2
--- response_body
bar = 4
foo = 3
--- error_log
lua hit query args limit 2
--- log_level: debug



=== TEST 35: max args (limited after an orphan key)
--- config
    location /lua {
        content_by_lua '
            local args = ngx.req.get_uri_args(2)
            local keys = {}
            for key, val in pairs(args) do
                table.insert(keys, key)
            end

            table.sort(keys)
            for i, key in ipairs(keys) do
                ngx.say(key, " = ", args[key])
            end
        ';
    }
--- request
GET /lua?foo=3&bar&baz=2
--- response_body
bar = true
foo = 3
--- error_log
lua hit query args limit 2
--- log_level: debug



=== TEST 36: max args (limited after an empty key, but non-emtpy values)
--- config
    location /lua {
        content_by_lua '
            local args = ngx.req.get_uri_args(2)
            local keys = {}
            for key, val in pairs(args) do
                table.insert(keys, key)
            end

            table.sort(keys)
            for i, key in ipairs(keys) do
                ngx.say(key, " = ", args[key])
            end

            ngx.say("done")
        ';
    }
--- request
GET /lua?foo=3&=hello&=world
--- response_body
foo = 3
done
--- error_log
lua hit query args limit 2
--- log_level: debug



=== TEST 37: default max 100 args
--- config
    location /lua {
        content_by_lua '
            local args = ngx.req.get_uri_args()
            local keys = {}
            for key, val in pairs(args) do
                table.insert(keys, key)
            end

            table.sort(keys)
            for i, key in ipairs(keys) do
                ngx.say(key, " = ", args[key])
            end
        ';
    }
--- request eval
my $s = "GET /lua?";
my $i = 1;
while ($i <= 102) {
    if ($i != 1) {
        $s .= '&';
    }
    $s .= "a$i=$i";
    $i++;
}
$s
--- response_body eval
my @k;
my $i = 1;
while ($i <= 100) {
    push @k, "a$i";
    $i++;
}
@k = sort @k;
for my $k (@k) {
    if ($k =~ /\d+/) {
        $k .= " = $&\n";
    }
}
CORE::join("", @k);
--- timeout: 4
--- error_log
lua hit query args limit 100
--- log_level: debug



=== TEST 38: custom max 102 args
--- config
    location /lua {
        content_by_lua '
            local args = ngx.req.get_uri_args(102)
            local keys = {}
            for key, val in pairs(args) do
                table.insert(keys, key)
            end

            table.sort(keys)
            for i, key in ipairs(keys) do
                ngx.say(key, " = ", args[key])
            end
        ';
    }
--- request eval
my $s = "GET /lua?";
my $i = 1;
while ($i <= 103) {
    if ($i != 1) {
        $s .= '&';
    }
    $s .= "a$i=$i";
    $i++;
}
$s
--- response_body eval
my @k;
my $i = 1;
while ($i <= 102) {
    push @k, "a$i";
    $i++;
}
@k = sort @k;
for my $k (@k) {
    if ($k =~ /\d+/) {
        $k .= " = $&\n";
    }
}
CORE::join("", @k);
--- timeout: 4
--- error_log
lua hit query args limit 102
--- log_level: debug



=== TEST 39: custom unlimited args
--- config
    location /lua {
        content_by_lua '
            local args = ngx.req.get_uri_args(0)
            local keys = {}
            for key, val in pairs(args) do
                table.insert(keys, key)
            end

            table.sort(keys)
            for i, key in ipairs(keys) do
                ngx.say(key, " = ", args[key])
            end
        ';
    }
--- request eval
my $s = "GET /lua?";
my $i = 1;
while ($i <= 105) {
    if ($i != 1) {
        $s .= '&';
    }
    $s .= "a$i=$i";
    $i++;
}
$s
--- response_body eval
my @k;
my $i = 1;
while ($i <= 105) {
    push @k, "a$i";
    $i++;
}
@k = sort @k;
for my $k (@k) {
    if ($k =~ /\d+/) {
        $k .= " = $&\n";
    }
}
CORE::join("", @k);
--- timeout: 4



=== TEST 40: rewrite uri and args (multi-value args)
--- config
    location /bar {
        echo $server_protocol $query_string;
    }
    location /foo {
        #rewrite ^ /bar?hello? break;
        rewrite_by_lua '
            ngx.req.set_uri_args({a = 3, b = {5, 6}})
            ngx.req.set_uri("/bar")
        ';
        proxy_pass http://127.0.0.1:$TEST_NGINX_SERVER_PORT;
    }
--- request
    GET /foo?world
--- response_body
HTTP/1.0 a=3&b=5&b=6



=== TEST 41: ngx.decode_args (sanity)
--- config
    location /lua {
        content_by_lua '
            local args = "a=bar&b=foo"
            args = ngx.decode_args(args)
            ngx.say("a = ", args.a)
            ngx.say("b = ", args.b)
        ';
    }
--- request
GET /lua
--- response_body
a = bar
b = foo



=== TEST 42: ngx.decode_args (multi-value)
--- config
    location /lua {
        content_by_lua '
            local args = "a=bar&b=foo&a=baz"
            args = ngx.decode_args(args)
            ngx.say("a = ", table.concat(args.a, ", "))
            ngx.say("b = ", args.b)
        ';
    }
--- request
GET /lua
--- response_body
a = bar, baz
b = foo



=== TEST 43: ngx.decode_args (empty string)
--- config
    location /lua {
        content_by_lua '
            local args = ""
            args = ngx.decode_args(args)
            ngx.say("n = ", #args)
        ';
    }
--- request
GET /lua
--- response_body
n = 0



=== TEST 44: ngx.decode_args (boolean args)
--- config
    location /lua {
        content_by_lua '
            local args = "a&b"
            args = ngx.decode_args(args)
            ngx.say("a = ", args.a)
            ngx.say("b = ", args.b)
        ';
    }
--- request
GET /lua
--- response_body
a = true
b = true



=== TEST 45: ngx.decode_args (empty value args)
--- config
    location /lua {
        content_by_lua '
            local args = "a=&b="
            args = ngx.decode_args(args)
            ngx.say("a = ", args.a)
            ngx.say("b = ", args.b)
        ';
    }
--- request
GET /lua
--- response_body
a = 
b = 



=== TEST 46: ngx.decode_args (max_args = 1)
--- config
    location /lua {
        content_by_lua '
            local args = "a=bar&b=foo"
            args = ngx.decode_args(args, 1)
            ngx.say("a = ", args.a)
            ngx.say("b = ", args.b)
        ';
    }
--- request
GET /lua
--- response_body
a = bar
b = nil



=== TEST 47: ngx.decode_args (max_args = -1)
--- config
    location /lua {
        content_by_lua '
            local args = "a=bar&b=foo"
            args = ngx.decode_args(args, -1)
            ngx.say("a = ", args.a)
            ngx.say("b = ", args.b)
        ';
    }
--- request
GET /lua
--- response_body
a = bar
b = foo



=== TEST 48: ngx.decode_args should not modify lua strings in place
--- config
    location /lua {
        content_by_lua '
            local s = "f+f=bar&B=foo"
            args = ngx.decode_args(s)
            for k, v in pairs(args) do
                ngx.say("key: ", k)
            end
            ngx.say("s = ", s)
        ';
    }
--- request
GET /lua
--- response_body
key: f f
key: B
s = f+f=bar&B=foo
--- no_error_log
[error]



=== TEST 49: ngx.decode_args should not modify lua strings in place (sample from Xu Jian)
--- config
    lua_need_request_body on;
    location /t {
        content_by_lua '
            function split(s, delimiter)
                local result = {}
                local from = 1
                local delim_from, delim_to = string.find(s, delimiter, from)
                while delim_from do
                    table.insert(result, string.sub(s, from, delim_from - 1))
                    from = delim_to + 1
                    delim_from, delim_to = string.find(s, delimiter, from)
                end
                table.insert(result, string.sub(s, from))
                return result
            end

            local post_data = ngx.req.get_body_data()

            local commands = split(post_data, "||")
            for _, command in pairs(commands) do
                --command = ngx.unescape_uri(command)
                local request_args = ngx.decode_args(command, 0)
                for key, value in pairs(request_args) do
                    ngx.say(key, ": ", value)
                end
                ngx.say(" ===============")
            end
        ';
    }
--- request
POST /t
method=zadd&key=User%3A1227713%3Alikes%3Atwitters&arg1=1356514698&arg2=780984852||method=zadd&key=User%3A1227713%3Alikes%3Atwitters&arg1=1356514698&arg2=780984852||method=zadd&key=User%3A1227713%3Alikes%3Atwitters&arg1=1356514698&arg2=780984852
--- response_body
arg2: 780984852
method: zadd
key: User:1227713:likes:twitters
arg1: 1356514698
 ===============
arg2: 780984852
method: zadd
key: User:1227713:likes:twitters
arg1: 1356514698
 ===============
arg2: 780984852
method: zadd
key: User:1227713:likes:twitters
arg1: 1356514698
 ===============
--- no_error_log
[error]


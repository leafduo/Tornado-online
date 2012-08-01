require 'rest_client'
require 'highline/import'
require 'digest'
require 'Logger'
require 'json'

class Tornado
    
    def initialize
        @cookies = {}
        @logger = Logger.new(STDERR)
    end

    def get_check_code
        check_code_uri = "http://check.ptlogin2.qq.com/check"
        res = RestClient.get check_code_uri,
            {:params => {:appid => 567008010,
            :uin => @username}}
        /ptui_checkVC\('(\d)','(.+)','(.+)'\);/.match(res.to_str) { |m|
            return_code = m[1]
            @verify_code = m[2]
            @uin = eval("\"#{m[3]}\"")
        }
        @cookies.merge! res.cookies
        @logger.info res.to_str
    end

    def auth
        auth_uri = "http://ptlogin2.qq.com/login"
        @username = ask("Enter username: ")
        get_check_code
        password = ask("Enter password: ") { |q| q.echo = false }
        password = Digest::MD5.digest(password)
        password = Digest::MD5.hexdigest(password + @uin).upcase
        password = Digest::MD5.hexdigest(password + @verify_code).upcase
        
        res = RestClient.get auth_uri,
            {:params => {:u => @username,
            :p => password,
            :verifycode => @verify_code,
            :aid => 567008010,
            :u1 => 'http://lixian.qq.com/main.html',
            :h => 1,
            :ptredirect => 1,
            :ptlang => 2052,
            :from_ui => 1,
            :fp => 'loginerroralert',
            :g => 1},
            :cookies => @cookies}
        @cookies.merge! res.cookies
        @logger.info res.to_str
        lixian_login_uri = 'http://lixian.qq.com/handler/lixian/do_lixian_login.php'
        res = RestClient.post lixian_login_uri, '', {:cookies => @cookies}
        @logger.info res.to_str
        @cookies.merge! res.cookies
    end

    def get_lixian_list
        lixian_list_uri = 'http://lixian.qq.com/handler/lixian/get_lixian_list.php'
        res = RestClient.post lixian_list_uri, '', {:cookies => @cookies}
        JSON.parse(res.to_str[1..-1])  # The result begins with \xfe\xff
    end

    def get_http_url(hash, filename)
        http_url = 'http://lixian.qq.com/handler/lixian/get_http_url.php'
        res = RestClient.post http_url, {:hash => hash, :filename => filename}, {:cookies => @cookies}
        puts JSON.parse(res.to_str[1..-1])   # The result begins with \xfe\xff
    end
end

t = Tornado.new
t.auth
t.get_http_url('6093ed37e62e05c0ca7767da50c0d3f9e345bc6f386308637f1d63c4ebaae0822024b2b2e3a1ff53', '[EMD][Binbougami ga!][04][BIG5][X264_AAC][1280X720].mp4')

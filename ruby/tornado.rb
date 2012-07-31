require 'rest_client'
require 'highline/import'
require 'digest'

class Tornado
    
    def initialize
        @cookies = Hash.new
    end

    def get_check_code()
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
    end

    def auth()
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
        puts res.to_str
        lixian_login_uri = 'http://lixian.qq.com/handler/lixian/do_lixian_login.php'
        res = RestClient.post lixian_login_uri, {:e=>1}, {:cookies => @cookies}
        @cookies.merge! res.cookies

        #TODO: To be removed
        list_uri = 'http://lixian.qq.com/handler/lixian/get_lixian_list.php'
        res = RestClient.post list_uri, {:e=>1}, {:cookies => @cookies}
        puts res.to_str
    end
end

t = Tornado.new
t.auth

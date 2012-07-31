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
            :uin => '358509641'}}
        /ptui_checkVC\('(\d)','(.+)','(.+)'\);/.match(res.to_str) { |m|
            return_code = m[1]
            @verify_code = m[2]
            @uin = eval("\"#{m[3]}\"")
        }
        @cookies.merge! res.cookies
        @cookies[:login_param] = 'uin%3D%26appid%3D567008010%26f_url%3Dloginerroralert%26hide_title_bar%3D1%26style%3D1%26s_url%3Dhttp%253A%2F%2Flixian.qq.com%2Fmain.html%26lang%3D0%26enable_qlogin%3D1%26css%3Dhttp%253A%2F%2Fimgcache.qq.com%2Fptcss%2Fr1%2Ftxyjy%2F567008010%2Flogin_mode_new.css%253F'
        @cookies[:ptcz] = '4ccdd8568de7d73c9bdcd09cc64370e4cdb24e23d8d4a412aedf120502ac3103'
        @cookies[:ptuserinfo] = '4c6561662044756f'
        @cookies[:uikey] = '934f4782c90716fd64990a9694cd4241badab16aaa1b23446680a6875e403278'
        @cookies[:chkuin] = '358509641'
        @cookies[:confirmuin] = '358509641'
        @cookies[:ptui_loginuin] = '358509641'
    end

    def auth()
        auth_uri = "http://ptlogin2.qq.com/login"
        # @username = ask("Enter username: ")
        @username = '358509641'
        password = ask("Enter password: ") { |q| q.echo = false }
        password = Digest::MD5.digest(password)
        password = Digest::MD5.hexdigest(password + "\x00\x00\x00\x00\x15\x5e\x6c\x49").upcase
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
            :dumy => '',
            :fp => 'loginerroralert',
            :action => '2-4-9954',
            :mibao_css => '',
            :t => 1,
            :g => 1},
            :cookies => @cookies}
        puts res.to_str
    end
end

t = Tornado.new
t.get_check_code
t.auth

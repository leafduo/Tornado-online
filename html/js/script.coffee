get_check_code = ->
    $.get("http://check.ptlogin2.qq.com/check?uin=leafduo@gmail.com&appid=567008010&r=0.8911660050507635",(data) ->
        data = data.toString()
        $(data).appendTo('#info')
    )

get_check_code()

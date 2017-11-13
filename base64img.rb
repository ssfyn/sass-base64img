#
# fyn: 将图片通过tinypng压缩，然后转为base64格式
# 使用方法：
# 1.scss:
#    body {
#        background-image:base64img("images/test.png");
#    }
# 2.命令行:
#    scss -r ./base64img.rb test.scss > test.css
#
# 注意：scss中写的图片路径是相对于运行scss命令时的目录
#

require "base64"
require "tinify" # TinyPNG的类库，需要先gem install tinify

Tinify.key = "YOUR KEY" # TinyPNG的API KEY，每月可以压缩500张不同的图片，同一张图片多次上传只算一次

module Sass::Script::Functions

    def base64img(filePath)
        # 文件的完整路径
        realFilePath = File::expand_path(filePath.value)
        # 文件名
        fileName = File::basename(realFilePath)
        # 文件目录
        sameDir = File::dirname(realFilePath)
        # 压缩后德尔新文件完整路径
        tinyFilePath = sameDir+"/tiny."+fileName
        # 文件类型，暂时从扩展名获取
        fileType = File::extname(fileName).downcase
        if fileType == ".jpg"
            fileType = ".jpeg"
        end
        if fileType != ".png" && fileType != ".jpeg" && fileType != ".gif"
            throw Exception.new("Ext not support: "+fileType)
        else
            # 去掉扩展名的第一个字符“.”
            fileType = fileType[1,fileType.length]
        end
        if File::exist?(realFilePath)
            # 读取文件
            source = Tinify.from_file(realFilePath)
            # 保存到文件
            source.to_file(tinyFilePath)
            # 转为base64字符串
            base64str = Base64.strict_encode64(source.to_buffer)
            # 返回给Sass(ruby可以不写return，最后一行代码就是返回值)
            Sass::Script::Value::String.new("url(\"data:image/"+fileType+";base64,"+base64str+"\")")
        else
            throw Exception.new("File not found: "+realFilePath)
        end
    end
    declare :base64img, [:filePath] # 这个是Sass里定义的函数
end

list = Dir.glob("c:/tmp/st/*.srt")
re = /([a-zA-Z' ,-.!?]+)|(..:..:..,... --> ..:..:..,...)/

File.open("c:/tmp/st/out", "w") do |out|
    list.each do |f|
        File.open(f).each_line do |line|
            line.scan(re) do |item|        
                out.write " "+item[0] if item[0]
            end
        end
    end
end
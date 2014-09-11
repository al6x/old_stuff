list = Dir.glob("c:/tmp/st/*.txt")
re = /[a-zA-Z']+/
phraze = 1
percent = 100

map = Hash.new(0)
list.each do |f|
    File.open(f).each_line do |line|
        words = []
        count = 0
        line.scan(re) do |item|
            item = item.downcase
            words.push item
            count += 1
            words.shift if count > phraze            
            map[words.join(' ')] += 1 if count >= phraze
        end
    end
end

sorted = map.sort{|a, b| b[1] <=> a[1]}
sum = 0
sorted.each{|a| sum += a[1]}

percent_sum = sum * percent / 100

p "Sum #{sum}"
p "Percent Sum #{percent_sum}"

out = File.new('c:/tmp/st/out', 'w')

accumulating_sum = 0
short_tail = []
sorted.each do |a|     
    accumulating_sum += a[1]    
    if accumulating_sum <= percent_sum
        out.write "#{a[0]}\n" #if a[1] > 1
        short_tail << a
    end
end

#require 'YAML'
#File.open('c:/tmp/st/short_tail', 'w').write YAML.dump(short_tail)

  
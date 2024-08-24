gem_path = `rake build`.split(' ').last.chomp('.')
if File.file?(gem_path)
  gem_ver = 'v' + gem_path.scan(/\d/).join('.')
  puts "Publishing gem '#{gem_ver}', right? 🤔"
  if gets.to_s.downcase =~ /y/
    puts 'okie dokie 🚀'
    output = `gem push #{gem_path}`
    puts output
    if output.include?('Successfully registered gem')
      puts `git tag #{gem_ver} && git push origin #{gem_ver}`
    end
  else
    puts 'okay 😐'
  end
else
  "Something wrong with '#{gem_path}' 🏌️‍♂️"
end

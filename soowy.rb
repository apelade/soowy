#!/usr/bin/env ruby
# TODO map reduce
# TODO rescue exceptions and report sep category for unavailable files?
# TODO trap SIG_INT and print results so far, then exit
# TODO check:
# does array subtraction benefit from sorted?
# non-in-place ary methods faster for short-line low-memory case?
# TODO may need to chunk if run on single-line files, eg compiled css
usage = "" "
  Usage:
  ruby soowy.rb -r regex -f file,file,..
  Example:
  ruby soowy.rb -r \"\w.*\w\" -f test1.txt,test2.txt
  or pipe command:
  find path/to/scss -type f -name test\\*.scss | xargs ruby soowy.rb -r \"/\./\w\" -f
  " ""
fail(usage) if ARGV.empty?

require 'optparse'
options = {}
OptionParser.new do |opts|

  DEFAULT_REGEX = %r{\w.*\w}
  options[:regex] = DEFAULT_REGEX
  options[:files] = []
  options[:verbose] = false
  opts.banner = usage
  opts.on("-r", "--regex \"#{options[:regex]}\"", "regex used to match candidates") do |regex|
    begin
      regex = Regexp.new(regex) unless regex.instance_of? Regexp
      options[:regex] = regex
    rescue RegexpError
      puts "Error creating regular expression from #{regex}"
    end
  end
  opts.on("-f", "--files file1,file2 ..", Array, "file list to search") do |files|
    options[:files] = files
  end
  opts.on("-v", "--[no-]verbose", "run verbosely") do |v|
    options[:verbose] = v
  end
end.parse!
using_default = "Using Default " if options[:regex] == DEFAULT_REGEX
puts using_default.to_s + "Regex : #{options[:regex]}" if using_default || options[:verbose]
unique = []

# find unique words from each file
options[:files].each do |file|
  raise "file not found: ${file}" unless File.exists? file
  raise "file not readable: ${file}" unless File.readable? file
  singles = []
  open(file) do |text|
    text.each_line do |line|
      words = line.scan options[:regex]
      # XOR arrays
      singles = (singles - words) + (words - singles)
      singles.sort!
    end
    puts "result for file #{file}:", singles.flatten if options[:verbose]
  end
  unique = (unique - singles) + (singles - unique)
  unique.sort!
end

if options[:verbose]
  puts "unique across files #{options[:files].join(",")} : #{unique}"
else
  puts unique
end


#!/usr/bin/env ruby
# TODO map reduce
# TODO rescue exceptions and report sep category for unavailable files?
# TODO trap SIG_INT and print results so far, then exit
# TODO check:
# does array subtraction benefit from sorted?
# non-in-place ary methods faster for short-line low-memory case?
# TODO may need to chunk if run on single-line files, eg compiled css

usage = """
Usage:
  ruby soowy.rb -r \'inner_regex\' -f file file --verbose
Example:
  ruby soowy.rb -r \'\\w.*\\w\' -f test1.txt test2.txt -v
Example piping from shell command:
  find ../websiteone/app/assets/stylesheets/ -type f -name *.scss | xargs ruby soowy.rb -r '\\A\.\\w.*\\w' -v
  """

require 'optparse'
options = {}
OptionParser.new(usage) do |opts|
  DEFAULT_REGEX = /\w.*\w/
  options[:regex] = DEFAULT_REGEX
  options[:verbose] = false
  opts.on("-r", "--regex \'\\w.*\\w\'", "single-quoted inner string for scan regex") do |regex|
    begin
      regex = Regexp.new(regex) unless regex.instance_of? Regexp
      options[:regex] = regex
    rescue RegexpError
      puts "Error creating regular expression from #{regex}"
      exit! 1
    end
  end
  opts.on("-v", "--[no-]verbose", "run verbosely") do |v|
    options[:verbose] = v
  end
  opts.parse!
  # anything left over is assumed to be a file name
  options[:files] = ARGV
  puts opts if options[:files].empty?
end.parse!
using_default = "Using Default " if options[:regex] == DEFAULT_REGEX
puts using_default.to_s + "Regex : #{options[:regex].to_s}" if using_default || options[:verbose]

# find unique words from each file
unique = []
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


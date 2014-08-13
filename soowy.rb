#!/usr/bin/env ruby

# TODO 1 replace SPLIT_ON with regex, allow user to provide
# TODO rescue exceptions and ARGV.delete file
# TODO option parser
# TODO trap SIG_INT and print results so far, then exit
# TODO check:
  # does array subtraction benefit from sorted?
  # non-in-place ary methods faster for short-line low-memory case?
# TODO may need to chunk if run on single-line files, eg compiled css
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  options[:regex] = ""
  options[:files] = []
  options[:verbose] = false
  opts.banner =
"""
Usage:
ruby soowy.rb file file..
or pipe command:
find path/to/scss -type f -name test\\*.txt | xargs ruby soowy.rb
"""

  opts.on("-r", "--regex /REGEX/", "regex used to match candidates") do |regex|
    options[:regex] << regex
  end

  opts.on("-f", "--files file1,file2 ..", Array, "file list to search") do |files|
    options[:files] = files
  end

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end

end.parse!

unique = []

options[:files].each do |file|
  raise "file not found: ${file}" unless File.exists? file
  raise "file not readable: ${file}" unless File.readable? file
  # find unique words from each file
  singles = []
  open(file) do |text|
    text.each_line do |line|
      unless line.nil? || line.match(options[:regex]).nil?
        words = line =~ (options[:regex]).uniq.sort
        # XOR arrays
        singles = (singles - words) + (words - singles)
        singles.sort!
        if options[:verbose]
          puts "result for file #{file}:"
          print singles.flatten
          print ''
        end
      end
    end
  end
  unique = (unique - singles) + (singles - unique)
  unique.sort!
end

puts "unique across files #{ARGV.join(" ")} :"
print unique
# if piping to another process puts format is better?
# puts unique


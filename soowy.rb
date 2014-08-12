#!/usr/bin/env ruby

# TODO 1 needs a regex, allow user to provide
# TODO option parser
# TODO trap SIG_INT and print results so far, then exit

SPLIT_ON = " "

fail """
Usage:
ruby soowy.rb file file..
or pipe from find:
find -type f -name test\\*.txt | xargs ruby soowy.rb
""" if ARGV.empty?


unique = []

ARGV.each do |file|
  raise "file not found: ${file}" unless File.exists? file rescue ARGV.delete(file)
  raise "file not readable: ${file}" unless File.readable? file  rescue ARGV.delete(file)
#  puts "Process file: #{file}"
  # find unique words from each file
  singles = []
  open(file) do |text|
    text.each_line do |line|
      # may need to chunk if run on single-line files, eg compiled css
      # does array subtraction benefit from sorted?
      # non-in-place ary methods faster for short-line case?

      words = line.split(SPLIT_ON).uniq.sort
      # XOR arrays
      singles = (singles - words) + (words - singles)
      singles.sort!
    end
  end
#  puts
#  puts "unique to #{file}:\n"
#  print singles
#  puts
  unique = (unique - singles) + (singles - unique)
  unique.sort!
end

puts "unique across files #{ARGV.join(" ")} :"
print unique
# if piping to another process puts format is better?
# puts unique


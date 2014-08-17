#!/usr/bin/env ruby
# TODO check:
# does array subtraction benefit from sorted?
# non-in-place ary methods faster for short-line low-memory case?
# need to chunk if run on single-line files, eg compiled css

require 'optparse'

class Soowy
  DEFAULT_REGEX = /\w.*\w/

  def self.usage
    "" "
  Usage: Find strings that occur only once in a set of files
    ruby soowy.rb -r \'inner_regex\' file file --verbose
  Example:
    ruby soowy.rb -r \'\\w.*\\w\' test1.txt test2.txt -v
  Example piping from shell command:
    find ../websiteone/app/assets/stylesheets/ -type f -name *.scss | xargs ruby soowy.rb -r '\\A\\.\\w.*\\w {'
  " ""
  end

  def self.parse_opts(usage)
    options = {}
    OptionParser.new(usage) do |opts|
      options[:regex] = ''
      options[:verbose] = false
      opts.on("-r", "--regex \'\\w.*\\w\'", "quoted inner string for scan regex") do |regex|
        begin
          regex = Regexp.new(regex) unless regex.instance_of? Regexp
          options[:regex] = regex
        rescue RegexpError => e
          raise "Error creating regular expression from #{regex} " + e.inspect
        end
      end
      opts.on("-v", "--[no-]verbose", "run verbosely") do |v|
        options[:verbose] = v
      end
      opts.parse!
      options[:files] = ARGV
      fail opts.to_s if options[:files].empty? && options[:regex] == ''
      options[:regex] = DEFAULT_REGEX if options[:regex] == ''
    end.parse!
    using_default = "Using Default " if options[:regex] == DEFAULT_REGEX
    puts using_default.to_s + "Regex : #{options[:regex].to_s}" if using_default || options[:verbose] || options[:files].empty?
    options
  end

  def self.find_unique(regex, files, verbose)
    unique = []
    files.each do |file|
      raise "file not found: ${file}" unless File.exists? file
      raise "file not readable: ${file}" unless File.readable? file
      singles = []
      open(file) do |text|
        text.each_line do |line|
          words = line.scan regex
          # XOR arrays
          singles = (singles - words) + (words - singles)
          singles.sort!
        end
        puts "result for file #{file}:", singles.flatten if verbose
      end
      unique = (unique - singles) + (singles - unique)
      unique.sort!
    end
    unique
  end

  def self.format_result(unique, files, verbose)
    if verbose
      "unique across files #{files.join(" ")} : #{unique}"
    else
      unique
    end
  end

end # end class Soowy

options = Soowy.parse_opts(Soowy.usage())
unique  = Soowy.find_unique(options[:regex], options[:files], options[:verbose])
puts Soowy.format_result(unique, options[:files], options[:verbose])


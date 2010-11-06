#!/usr/bin/env ruby
# Detabify.rb
# A tool by Adam Hintz
# The source code in this file is available under the following license (MIT):

# Copyright (c) 2010 Adam Hintz
# Permission is hereby granted, free of charge, to any person obtaining a copy 
# of this software and associated documentation files (the "Software"), to deal 
# in the Software without restriction, including without limitation the rights 
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
# copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in 
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
# THE SOFTWARE.

numSpaces = ARGV[0]

(args = Array.new ARGV).delete_at 0

args.each do |arg|
  newFile = Array.new
  if File.directory?(arg) then
    dirContents = Dir.entries(arg)
    dirContents.delete(".")
    dirContents.delete("..")
    dirContents.collect! do |dirContent|
      puts (arg + ", " + dirContent)
      arg + "/" + dirContent
    end
    
    (args << dirContents).flatten!
  else
    puts "Modifying file " + arg
    File.open(arg, "r").each do |line|
      newFile << line.gsub(/\t/, "    ")
    end
    
    outFile = File.open(arg, "w")
    newFile.each do |line|
      outFile.write line
    end
    outFile.close
  end
end


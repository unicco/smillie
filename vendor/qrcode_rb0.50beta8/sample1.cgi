#!/usr/local/bin/ruby
#
# QRcode library sample for ruby 
#
# This is a cgi program to makes a QRcode
#  to use many images.
#
# You must set 'b.png' and 'd.png' on document root.
#
# usage
#  sample1.cgi?d=[data](&v=[1-40])(&e=[L,M,Q,H])
#

require "./qrcode.rb"
require "cgi"

cgi=CGI.new
params=cgi.params

print "Content-type: text/html\n\n"
x=Qrcode.new

if params.key?("d") then
 d=params["d"].to_s
else
 print "no data"
 exit
end

if params.key?("v") then
 x.set_qrcode_version(params["v"][0].to_i)
end

if params.key?("e") then
 x.set_qrcode_error_correct(params["e"][0].to_s)
end

s=x.make_qrcode(d)

s.gsub!("0","<IMG SRC=\"/b.png\">")
s.gsub!("1","<IMG SRC=\"/d.png\">")
s.gsub!("\n","<BR>\n")

print s


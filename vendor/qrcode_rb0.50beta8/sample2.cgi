#!/usr/local/bin/ruby
#
# QRcode library sample for Ruby 
#
# This is a cgi program to output a QRcode PNG image.
#
# This program requires Ruby-GD.
#
# usage
#  sample2.cgi?d=[data](&v=[1-40])(&e=[L,M,Q,H])
# 

require "./qrcode_img.rb"
require "cgi"

cgi=CGI.new
params=cgi.params

print "Content-type: image/png\n\n"
x=Qrcode_image.new

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


#x.image_out(x.make_qrcode(d),'png')     # old style
x.qrcode_image_out(d,'png')


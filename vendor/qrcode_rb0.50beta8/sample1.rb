#!/usr/local/bin/ruby

require "./qrcode.rb"

d="testdata"
x = Qrcode.new
out = x.make_qrcode(d)
print out

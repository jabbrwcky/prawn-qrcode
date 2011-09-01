# Copyright 2011 Jens Hausherr
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
require 'rubygems'
require 'prawn/core'
require 'prawn/measurement_extensions'
require_relative '../lib/prawn/qrcode'

qrcode = 'https://github.com/jabbrwcky/prawn-qrcode'

Prawn::Document::new(:page_size => "A4") do
  text "Sample autosized QR-Code (with stroked bounds). Size of dots : 3mm (huge)"
  print_qr_code(qrcode, :dot=>3.send(:mm))
  move_down 20

  text "Sample QR-Code (with and without stroked bounds) using dots with size: 1 mm (~2.8pt)"
  cpos = cursor
  print_qr_code(qrcode, :dot=>1.send(:mm))
  print_qr_code(qrcode, :pos=>[150,cpos], :dot=>1.send(:mm), :stroke=>false)
  move_down 20

  text "Higher ECC Levels (may) increase module size. "+
           "This QR Code uses ECC Level Q (ca. 30% of symbols can be recovered)."
  print_qr_code(qrcode, :dot=>1.send(:mm), :level=>:q)

  render_file("dotsize.pdf")
end
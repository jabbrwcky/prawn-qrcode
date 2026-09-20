# Copyright 2011 - 2026 Jens Hausherr
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
# frozen_string_literal: true

require 'benchmark'
require_relative '../lib/prawn/qrcode'

REPETITIONS = Integer(ENV.fetch('REPETITIONS', '25'))
PAYLOAD_SIZES = [16, 64, 256, 1024, 2048].freeze

def render(qr_code)
  pdf = Prawn::Document.new(page_size: 'A4')
  pdf.render_qr_code(qr_code)
  pdf
end

puts format('%-10s %-9s %12s %14s', 'payload', 'modules', 'ms/render', 'stream bytes')

PAYLOAD_SIZES.each do |size|
  qr_code = Prawn::QRCode.min_qrcode('A' * size)
  stream_bytes = render(qr_code).page.content.stream.filtered_stream.bytesize
  elapsed = Benchmark.realtime { REPETITIONS.times { render(qr_code) } }

  puts format('%-10s %-9d %12.3f %14d', "#{size} B", qr_code.modules.length,
              elapsed / REPETITIONS * 1000, stream_bytes)
end

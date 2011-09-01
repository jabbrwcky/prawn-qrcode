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
require 'prawn'
require 'rqrcode'

# Extension for Prawn::Document for rendering QR codes.
module QRCode

  def print_qr_code(pos, content, width, ecc_level, stroke)
    size=0
    begin
      size +=1
      qr_code = RQRCode::QRCode.new(content, :size=> size, :level=> ecc_level)
      dot_size = width/(8+qr_code.modules.length)
      render_qr_code(pos, qr_code, dot_size, width, width, stroke)
    rescue QRCodeRunTimeError
      if size <40
        retry
      else
        raise
      end
    end
  end

  # @param qr_code [RQRCode::QRCode]
  # @param pos [Object]
  # @param dot [Object]
  # @param stroke [Boolean]
  def render_qr_code(pos, qr_code, dot, width=8*dot +code.modules.length * dot, height=width, stroke=true)
    bounding_box position, :width => width, :height => height do |box|
      if stroke
        stroke_bounds
      end

      pos_y = 4*dot +code.modules.length * dot

      qr_code.modules.each_index do |row|
        pos_x = 4*dot
        qr_code.modules.each_index do |col|
          move_to [pos_x, pos_y]
          if qr_code.dark?(row, col)
            fill { rectangle([pos_x, pos_y], dot, dot) }
          end
          pos_x = pos_x + dot
        end
        pos_y = pos_y - dot
      end
    end
  end

end

Prawn::Document.extensions << QRCode

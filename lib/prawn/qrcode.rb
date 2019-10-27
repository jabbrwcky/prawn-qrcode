#--
# Copyright 2010-2014 Jens Hausherr
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
#++
require 'prawn'
require 'rqrcode'

# :title: Prawn/QRCode
#
# :main: This is an extension for Prawn::Document to simplify rendering QR Codes.
# The module registers itself as Prawn extension upon loading.
#
# *Author*::    Jens Hausherr  (mailto:jabbrwcky@googlemail.com)
# *Copyright*:: Copyright (c) 2011 Jens Hausherr
# *License*::   Apache License, Version 2.0
#
module Prawn
  module QRCode
    # The default size for QR Code modules is 1/72 in
    DEFAULT_DOTSIZE = 1.to_f

    # Prints a QR Code to the PDF document. The QR Code creation happens on the fly.
    #
    # content::  The string to render as content of the QR Code
    #
    # *options:: Named optional parameters
    #
    #   +:level+:: Error correction level to use. One of: (:l,:m,:h,:q), Defaults to :m
    #   +:extent+:: Size of QR Code given in pt (1 pt == 1/72 in)
    #   +:pos+:: Two-element array containing the position at which the QR-Code should be rendered. Defaults to [0,cursor]
    #   +:dot+:: Size of QR Code module/dot. Calculated from extent or defaulting to 1pt
    #   +:stroke+:: boolean value whether to draw bounds around the QR Code.
    #             Defaults to true.
    #   +:margin+:: Size of margin around code in QR-Code modules/dots, Default to 4
    #   +:align+:: Optional alignment within the current bounding box. Valid values are :left, :right, and :center. If set
    #             This option overrides the horizontal positioning specified in :pos. Defaults to nil.
    #   +:debug+:: Optional boolean, renders a coordinate grid around the QRCode if true (uses Prawn#stroke_axis)
    #
    def print_qr_code(content, level: :m, dot: DEFAULT_DOTSIZE, pos: [0, cursor], stroke: true, margin: 4, **options)
      qr_version = 0
      dot_size = dot

      begin
        qr_version += 1
        qr_code = RQRCode::QRCode.new(content, size: qr_version, level: level)
        dot = options[:extent] / (2 * margin + qr_code.modules.length) if options[:extent]

        render_qr_code(qr_code, dot: dot, pos: pos, stroke: stroke, margin: margin, **options)
      rescue RQRCodeCore::QRCodeRunTimeError
        if qr_version < 40
          retry
        else
          raise
          end
      end
    end

    # Renders a prepared QR Code (RQRCode::QRCode) object.
    #
    # qr_code:: The QR Code (an RQRCode::QRCode) to render
    #
    # *options:: Named optional parameters
    #   +:extent+:: Size of QR Code given in pt (1 pt == 1/72 in)
    #   +:pos+:: Two-element array containing the position at which the QR-Code should be rendered. Defaults to [0,cursor]
    #   +:dot+:: Size of QR Code module/dot. Calculated from extent or defaulting to 1pt
    #   +:stroke+:: boolean value whether to draw bounds around the QR Code. Defaults to true.
    #   +:margin+:: Size of margin around code in QR-Code modules/dots, Default to 4
    #   +:align+:: Optional alignment within the current bounding box. Valid values are :left, :right, and :center. If set
    #             This option overrides the horizontal positioning specified in :pos. Defaults to nil.
    #   +:debug+:: Optional boolean, renders a coordinate grid around the QRCode if true (uses Prawn#stroke_axis)
    #
    def render_qr_code(qr_code, dot: DEFAULT_DOTSIZE, pos: [0, cursor], stroke: true, foreground_color: '000000', background_color: 'FFFFFF', stroke_color: '000000', margin: 4, **options)
      extent ||= (2 * margin + qr_code.modules.length) * dot

      case options[:align]
      when :center
        pos[0] = (@bounding_box.right / 2) - (extent / 2)
      when :right
        pos[0] = @bounding_box.right - extent
      when :left
        pos[0] = 0
      end

      fill_color background_color

      bounding_box(pos, width: extent, height: extent) do |_box|
        fill_color foreground_color
        pos_y = margin * dot + qr_code.modules.length * dot

        qr_code.modules.each_index do |row|
          pos_x = margin * dot
          dark_col = 0
          qr_code.modules.each_index do |col|
            move_to [pos_x, pos_y]
            if qr_code.qrcode.checked?(row, col)
              dark_col += 1
            else
              if dark_col > 0
                fill { rectangle([pos_x - dark_col * dot, pos_y], dot * dark_col, dot) }
                dark_col = 0
              end
            end
            pos_x += dot
          end
          if dark_col > 0
            fill { rectangle([pos_x - dark_col * dot, pos_y], dot * dark_col, dot) }
          end
          pos_y -= dot
        end

        if stroke
          fill_color stroke_color
          stroke_bounds
        end
        stroke_axis(at: [-1, -1], negative_axes_length: 0, color: '0C0C0C', step_length: 50) if options[:debug]
      end
    end
  end
end

Prawn::Document.extensions << Prawn::QRCode

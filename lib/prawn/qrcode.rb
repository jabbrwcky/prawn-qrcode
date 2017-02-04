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
    #   +:align+:: Optional alignment within the current bounding box. Valid values are :left, :right, and :center. If set
    #             This option overrides the horizontal positioning specified in :pos. Defaults to nil.
    #
    def print_qr_code(content, *options)
      opt = options.extract_options!
      qr_version = 0
      level = opt[:level] || :m
      extent = opt[:extent].nil? ? nil : opt[:extent].to_f
      dot_size = DEFAULT_DOTSIZE
      dot_size = opt[:dot].to_f if opt[:dot]

      begin
        qr_version += 1
        qr_code = RQRCode::QRCode.new(content, size: qr_version, level: level)

        dot_size = extent / (8 + qr_code.modules.length) unless extent.nil?

        render_qr_code(qr_code, opt.merge(dot: dot_size))
      rescue RQRCode::QRCodeRunTimeError
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
    #   +:align+:: Optional alignment within the current bounding box. Valid values are :left, :right, and :center. If set
    #             This option overrides the horizontal positioning specified in :pos. Defaults to nil.
    def render_qr_code(qr_code, *options)
      opt = options.extract_options!
      dot = DEFAULT_DOTSIZE
      dot = opt[:dot].to_f if opt[:dot]

      extent = opt[:extent].to_f || (8 + qr_code.modules.length) * dot
      stroke = true
      stroke = opt[:stroke] if opt.key?(:stroke)

      foreground_color = opt[:foreground_color] || '000000'
      background_color = opt[:background_color] || 'FFFFFF'
      stroke_color = opt[:stroke_color] || '000000'

      pos = opt[:pos] || [0, cursor]

      align = opt[:align]
      case align
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
        pos_y = 4 * dot + qr_code.modules.length * dot

        qr_code.modules.each_index do |row|
          pos_x = 4 * dot
          dark_col = 0
          qr_code.modules.each_index do |col|
            move_to [pos_x, pos_y]
            if qr_code.dark?(row, col)
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
      end
    end
end

Prawn::Document.extensions << Prawn::QRCode

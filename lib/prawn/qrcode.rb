#--
# Copyright 2010 - 2019 Jens Hausherr
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
# *Author*::    Jens Hausherr  (mailto:jabbrwcky@gmail.com)
# *Copyright*:: Copyright (c) 2011 -2019 Jens Hausherr
# *License*::   Apache License, Version 2.0
#
module Prawn
  module QRCode
    # DEFAULT_DOTSIZE defines the default size for QR Code modules in multiples of 1/72 in
    DEFAULT_DOTSIZE = 1.to_f

    def self.min_qrcode(content, qr_version = 0, dot: DEFAULT_DOTSIZE, level: :m, margin: 4, extent: nil, **)
      qr_version += 1

      qr_code = RQRCode::QRCode.new(content, size: qr_version, level: level)
      dot = dotsize(extent, margin, qr_code.modules.length) if extent

      [qr_code, dot]
    rescue RQRCodeCore::QRCodeRunTimeError
      retry if qr_version < 40
      raise
    end

    def self.dotsize(extent, margin, modules)
      extent.to_f / (2.to_f * margin.to_f + modules.to_f)
    end


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
    #             this option overrides the horizontal positioning specified in :pos. Defaults to nil.
    #   +:debug+:: Optional boolean, renders a coordinate grid around the QRCode if true (uses Prawn#stroke_axis)
    #
    def print_qr_code(content, level: :m, dot: DEFAULT_DOTSIZE, pos: [0, cursor], stroke: true, margin: 4, **options)
      qr_code, dot = Prawn::QRCode.min_qrcode(content, dot: dot, level: level, margin: margin, **options)
      render_qr_code(qr_code, dot: dot, pos: pos, stroke: stroke, margin: margin, **options)
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
    def render_qr_code(qr_code, **options)
      renderer = Renderer.new(qr_code, **options)
      renderer.render(self)
    end

    class Renderer
      attr_accessor :qr_code

      RENDER_OPTS = %I[dot pos stroke foreground_color background_color stroke_color margin align debug extent level]
      RENDER_OPTS.each { |attr| attr_writer attr }

      def initialize(qr_code, options)
        @qr_code = qr_code
        options.select{ |k,v| RENDER_OPTS.include?(k) }.each { |k, v| send("#{k}=", v) }
      end

      def dot
        @dot ||= Prawn::QRCode.dotsize(@extent, margin, qr_code.modules.length) if @extent
        @dot ||= DEFAULT_DOTSIZE unless @extent
        @dot
      end

      def stroke
        return @stroke unless @stroke.nil?

        @stroke ||= true
      end

      def foreground_color
        @foreground_color ||= '000000'
      end

      def background_color
        @background_color ||= 'FFFFFF'
      end

      def stroke_color
        @stroke_color ||= '000000'
      end

      def margin
        @margin ||= 4
      end

      def extent
        @extent ||= (2 * margin + qr_code.modules.length) * dot
        @extent
      end

      def margin_size
        margin * dot
      end

      def align(bounding_box)
        rlim = bounding_box.right
        case @align
        when :center
          @point[0] = (rlim / 2) - (extent / 2)
        when :right
          @point[0] = rlim - extent
        when :left
          @point[0] = 0
        end
      end

      # rubocop:disable Metrics/AbcSize
      def render(pdf)
        pdf.fill_color background_color

        pdf.bounding_box(pos(pdf), width: extent, height: extent) do |_box|
          pdf.fill_color foreground_color
          margin_dist = margin * dot

          m = qr_code.modules

          pos_y = margin_dist + m.length * dot

          m.each_with_index do |row, index|
            pos_x = margin_dist
            dark_col = 0

            row.each_index do |col|
              pdf.move_to [pos_x, pos_y]
              if qr_code.qrcode.checked?(index, col)
                dark_col += 1
              else
                if dark_col > 0
                  dark_col_extent = dark_col * dot
                  pdf.fill { pdf.rectangle([pos_x - dark_col_extent, pos_y], dark_col_extent, dot) }
                  dark_col = 0
                end
              end
              pos_x += dot
            end

            pdf.fill { pdf.rectangle([pos_x - dark_col * dot, pos_y], dot * dark_col, dot) } if dark_col > 0

            pos_y -= dot
          end

          if stroke
            pdf.fill_color stroke_color
            pdf.stroke_bounds
          end
          pdf.stroke_axis(at: [-1, -1], negative_axes_length: 0, color: '0C0C0C', step_length: 50) if debug
        end
      end

      private

      attr_reader :debug

      def pos(pdf)
        @pos ||= [0, pdf.cursor]
      end
    end
  end
end

Prawn::Document.extensions << Prawn::QRCode

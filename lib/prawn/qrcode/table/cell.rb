require 'prawn/table/cell'

module Prawn
  module QRCode
    module Table
      # QRCode is a table cell that renders a QR coe inside a table
      class Cell < Prawn::Table::Cell

        QR_OPTIONS = %I[content qr_code renderer level extent pos dot stroke margin align]
        CELL_OPTS = %I[padding borders border_widths border_colors border_lines colspan rowspan at]

        QR_OPTIONS.each { |attr| attr_writer attr }

        def initialize(pdf, pos, **options)
          super(pdf,pos,options.select{ |k,v|  CELL_OPTS.include?(k) })
          @margin = 4
          @options=options.reject{|k,v|  CELL_OPTS.include?(k) }
          @options.each{ |k,v| send("#{k}=", v)}
        end

        def natural_content_width
          renderer.extent
        end

        def natural_content_height
          renderer.extent
        end

        def draw_content
          renderer.render(@pdf)
        end

        def renderer
          @renderer ||= Prawn::QRCode::Renderer.new(qr_code, **@options)
        end

        def qr_code
          @qr_code, @dot = Prawn::QRCode.min_qrcode(content, **@options) if @qr_code.nil?
          @qr_code
        end
      end
    end
  end
end

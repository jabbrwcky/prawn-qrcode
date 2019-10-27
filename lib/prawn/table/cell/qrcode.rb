module Prawn
  class Table
    class Cell
      # QRCode is a table cell that renders a QR coe inside a table
      class QRCode < Cell
        %I[content qr_code renderer level extent pos dot stroke margin align].each { |p| attr_writer p }

        def natural_content_width
          @renderer.extent
        end

        def natural_content_height
          @renderer.extent
        end

        def draw_content
          renderer.render(@pdf)
        end

        def renderer
          @renderer ||= Prawn::QRCode::Renderer.new(qr_code)
        end

        def qr_code
          @qr_code ||= Prawn::QRCode.min_qrcode(content)
        end
      end
    end
  end
end

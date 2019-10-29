require_relative 'table/cell'

module Prawn
  module QRCode
    module Table
      def make_qrcode_cell(**options)
        Prawn::QRCode::Table::Cell.new(self, [0,cursor], options)
      end
    end
  end
end
Prawn::Document.extensions << Prawn::QRCode::Table

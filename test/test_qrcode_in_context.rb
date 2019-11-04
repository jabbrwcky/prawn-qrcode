require 'minitest/autorun'
require 'prawn/qrcode'
require 'prawn/document'

class TestQrcodeInContext < Minitest::Test
  def test_render_with_margin
    context = Prawn::Document.new
    assert(context.print_qr_code('HELOWORLD', margin: 0))
  end
end

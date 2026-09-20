require 'minitest/autorun'
require_relative '../lib/prawn/qrcode.rb'

class TestRenderer < Minitest::Test
  def setup
    @qrcode = Prawn::QRCode.min_qrcode('https://gituhb.com/jabbrwcky/prawn-qrcode')
  end

  def test_renderer_defaults
    r = Prawn::QRCode::Renderer.new(@qrcode)

    assert(r.stroke)
    assert_equal(Prawn::QRCode::DEFAULT_DOTSIZE, r.dot)
    assert_equal('000000', r.foreground_color)
    assert_equal('FFFFFF', r.background_color)
    assert_equal(4, r.margin)
    assert_equal(37.0, r.extent)
  end

  def test_renderer_extent
    r = Prawn::QRCode::Renderer.new(@qrcode, extent: 72)
    assert_in_delta(1.9, 0.05, r.extent)
  end

  def test_conflicting_dotsize_and_extent
    assert_raises(Prawn::QRCode::QRCodeError) { Prawn::QRCode::Renderer.new(@qrcode, dot: 3, extent: 72) }
  end

  def test_stroke_color_is_applied_to_the_stroke
    pdf = Prawn::Document.new(page_size: 'A4')
    pdf.render_qr_code(@qrcode, stroke_color: '0000FF')

    # SCN (upper case) sets the stroking color, scn the non-stroking (fill) color.
    stroking_colors = pdf.page.content.stream.filtered_stream.lines.grep(/SCN/).map(&:strip)

    assert_includes(stroking_colors, '0.0 0.0 1.0 SCN')
  end

  def test_rendered_output_covers_exactly_the_dark_modules
    pdf = Prawn::Document.new(page_size: 'A4')
    pdf.render_qr_code(@qrcode, margin: 0, dot: 1, stroke: false)

    assert_equal(dark_modules, painted_modules(pdf))
  end

  private

  def dark_modules
    size = @qrcode.modules.length
    (0...size).flat_map { |row| (0...size).map { |col| [row, col] if @qrcode.checked?(row, col) } }.compact.sort
  end

  # Maps the rectangles painted into the content stream back to module coordinates.
  # With dot size 1 and no margin a module is exactly 1 pt, so the rectangles can be
  # anchored on the top left dark module of the finder pattern.
  def painted_modules(pdf)
    rects = pdf.page.content.stream.filtered_stream
               .scan(/([\d.-]+) ([\d.-]+) ([\d.-]+) ([\d.-]+) re/)
               .map { |rect| rect.map(&:to_f) }
    left = rects.map { |x, _y, _w, _h| x }.min
    top = rects.map { |_x, y, _w, h| y + h }.max

    rects.flat_map do |x, y, w, h|
      row = (top - (y + h)).round
      col = (x - left).round
      h.round.times.flat_map { |dy| w.round.times.map { |dx| [row + dy, col + dx] } }
    end.uniq.sort
  end
end

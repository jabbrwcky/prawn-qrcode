require 'minitest/autorun'
require 'pdf/inspector'
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

    colors = PDF::Inspector::Graphics::Color.analyze(pdf.render)

    assert_equal([0.0, 0.0, 1.0], colors.stroke_color)
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

  # Maps the painted rectangles back to module coordinates. With dot size 1 and no
  # margin a module is exactly 1 pt, so the rectangles can be anchored on the top left
  # dark module of the finder pattern. Rectangle points are the lower left corner.
  def painted_modules(pdf)
    rects = PDF::Inspector::Graphics::Rectangle.analyze(pdf.render).rectangles
    left = rects.map { |rect| rect[:point].first }.min
    top = rects.map { |rect| rect[:point].last + rect[:height] }.max

    rects.flat_map do |rect|
      x, y = rect[:point]
      row = (top - (y + rect[:height])).round
      col = (x - left).round
      rect[:height].round.times.flat_map do |dy|
        rect[:width].round.times.map { |dx| [row + dy, col + dx] }
      end
    end.uniq.sort
  end
end

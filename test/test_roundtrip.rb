require 'minitest/autorun'
require 'open3'
require 'tmpdir'
require_relative '../lib/prawn/qrcode.rb'

# Renders QR codes, rasterizes the resulting PDF and decodes them again, verifying that a
# rendered code actually scans rather than merely being geometrically correct.
#
# Needs pdftoppm (poppler-utils) and zbarimg (zbar-tools); skipped when either is missing.
#
# The codes are rendered at an explicit extent rather than at the default dot size of
# 1 pt: a 1 pt dot puts a 29 module code into 0.4 in, and whether that still scans depends
# on the decoder's own sampling heuristics rather than on this library. It decodes at
# 300 dpi but not at 150 or 600, which would make for a flaky test.
class TestRoundTrip < Minitest::Test
  CONTENT = 'https://github.com/jabbrwcky/prawn-qrcode'
  EXTENT = 144
  RESOLUTION = 150

  def setup
    missing = %w[pdftoppm zbarimg].reject { |tool| executable?(tool) }
    skip "missing #{missing.join(' and ')}" unless missing.empty?
  end

  def test_decodes_to_its_content
    assert_equal(CONTENT, decode { |pdf| pdf.print_qr_code(CONTENT, extent: EXTENT) })
  end

  def test_decodes_with_the_highest_error_correction_level
    assert_equal(CONTENT, decode { |pdf| pdf.print_qr_code(CONTENT, level: :h, extent: EXTENT) })
  end

  def test_decodes_when_aligned_in_the_bounding_box
    assert_equal(CONTENT, decode { |pdf| pdf.print_qr_code(CONTENT, align: :right, extent: EXTENT) })
  end

  def test_decodes_a_payload_spanning_a_larger_matrix
    content = ([CONTENT] * 6).join(' ')

    assert_equal(content, decode { |pdf| pdf.print_qr_code(content, extent: EXTENT) })
  end

  private

  def executable?(tool)
    ENV.fetch('PATH', '').split(File::PATH_SEPARATOR).any? do |dir|
      path = File.join(dir, tool)
      File.file?(path) && File.executable?(path)
    end
  end

  # Renders the block into a PDF, rasterizes the first page and returns the content
  # decoded from the QR code it contains.
  def decode
    Dir.mktmpdir do |dir|
      pdf = Prawn::Document.new(page_size: 'A4')
      yield pdf

      pdf_path = File.join(dir, 'qrcode.pdf')
      File.binwrite(pdf_path, pdf.render)

      image = rasterize(pdf_path, File.join(dir, 'page'))
      out, status = Open3.capture2e('zbarimg', '-q', '--raw', image)
      raise "zbarimg failed (#{status.exitstatus}): #{out}" unless status.success?

      out.strip
    end
  end

  def rasterize(pdf_path, base)
    out, status = Open3.capture2e('pdftoppm', '-gray', '-r', RESOLUTION.to_s, '-singlefile', pdf_path, base)
    raise "pdftoppm failed (#{status.exitstatus}): #{out}" unless status.success?

    "#{base}.pgm"
  end
end

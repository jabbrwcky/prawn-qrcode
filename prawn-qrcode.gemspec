PRAWN_QRCODE_VERSION = "0.1.0"

Gem::Specification.new do |spec|
  spec.name = "prawn-qrcode"
  spec.version = PRAWN_QRCODE_VERSION
  spec.platform = Gem::Platform::RUBY
  spec.summary = "Print QR-Codes in PDF"
  spec.files =  Dir.glob("{examples,lib}/**/**/*") +
                      ["Rakefile", "prawn-qrcode.gemspec"]
  spec.require_path = "lib"
  spec.required_ruby_version = '>= 1.8.7'
  spec.required_rubygems_version = ">= 1.3.6"

  spec.extra_rdoc_files = %w{README.md LICENSE COPYING}
  spec.rdoc_options << '--title' << 'Prawn/QRCode Documentation' <<
                       '--main'  << 'README.md' << '-q'
  spec.authors = ["Jens Hausherr"]
  spec.email = ["jabbrwcky@googlemail.com"]
  #spec.rubyforge_project = "prawn-qrcode"
  spec.add_dependency('prawn', '~>0.11.1')
  spec.add_dependency('rqrcode', '~>0.4.1')
  spec.homepage = "http://github.com/jabbrwcky/prawn-qrcode"
  spec.description = <<END_DESC
  Prawn/QRCode simplifies the generation and rendering of QRCodes in Prawn PDF documents.
END_DESC
end
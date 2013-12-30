# Copyright 2011 Jens Hausherr
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

Gem::Specification.new do |spec|
  spec.name = "prawn-qrcode"
  spec.version = "0.2.1"
  spec.platform = Gem::Platform::RUBY
  spec.summary = "Print QR Codes in PDF"
  spec.files =  Dir.glob("{examples,lib}/**/**/*") +
                      ["Rakefile", "prawn-qrcode.gemspec"]
  spec.require_path = "lib"
  spec.required_ruby_version = '>= 1.8.7'
  spec.required_rubygems_version = ">= 1.3.6"

  spec.extra_rdoc_files = %w{README.md LICENSE}
  spec.rdoc_options << '--title' << 'Prawn/QRCode Documentation' <<
                       '--main'  << 'README.md' << '-q'
  spec.authors = ["Jens Hausherr"]
  spec.email = ["jabbrwcky@googlemail.com"]
  #spec.rubyforge_project = "prawn-qrcode"
  spec.add_dependency('prawn', '>= 0.11.1')
  spec.add_dependency('rqrcode', '>=0.4.1')
  spec.homepage = "http://github.com/jabbrwcky/prawn-qrcode"
  spec.description = <<END_DESC
  Prawn/QRCode simplifies the generation and rendering of QRCodes in Prawn PDF documents.
  QR Codes
END_DESC
end

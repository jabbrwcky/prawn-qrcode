# Prawn/QRCode: A simple extension to generate and/or render QRCodes for Prawn PDFs

Prawn/QRCode is a Prawn (~> 0.11.1) extension to simplify rendering of QRCodes.

## Install

```bash
$ gem install prawn-qrcode
```

## Usage

```ruby
require 'prawn/qrcode'

qrcode_content = "http://github.com/jabbrwcky/prawn-qrcode"
qrcode = RQRCode::QRCode.new("http://github.com/jabbrwcky/prawn-qrcode", :level=>:h, :size => 5)

# Render a prepared QRCode
TODO
# Render a code for raw content and a given size
TODO
# Render a code for raw content with a given dot size
TODO
```


For a full list of examples, take a look in the `examples` folder.

## Contributors

- [Jens Hausherr](mailto:jabbrwcky@googlemail.com)

# CHANGELOG

## 0.1.0

* Initial Release

## 0.1.1

* Updated prawn dependency from exact requirement of 0.11.1 to an >=0.11.1, <0.13

## 0.1.2

* Integrated patch to reduce rectangle count, which leads to a overall size reduction
of the generated PDF (bdurette)

## 0.2.0

* Integrated patch from bdurette to align QR Code within its bounding box.
  Adds the optional parameter :align (:left, :center, :right) to both
  render_qr_code() and print_qr_code()

## 0.2.1

* Updated prawn dependnecy spec to >= 0.11.1.

## 0.2.2

* Fixed default stroke and explicit conversion of extents to floats.

## 0.2.2.1

* Stroke param broken. Replaced with simpler evaluation.

## v0.3

* Update required Ruby version to 2.0
* Update minimal Prawn version to 1.0
* Fix rendering bugs due to slight changes in Prawn API
* Added optional (boolean) `:debug` parameter that renders a `stroke_axis` around the rendered QR Code

## v0.3.1

* Add custom margin option

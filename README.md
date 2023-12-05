Hyde Fonts
==========

A Jekyll 4 plugin for loading Google Fonts from a manifest


Installation
------------

1. Add Hyde Fonts to your Gemfile

`gem 'hyde-fonts', '~> 0.3.0'`

2. Add entry to your Jekyll config under plugins

```yaml
plugins:
  - hyde_fonts
  ...
```

3. Add the liquid tag to your layout

```liquid
{% hyde_fonts %}
```

which will render as the following, based on the configuration

```html
<link href="assets/fonts/fonts.css" rel="stylesheet" />
```

Adding `inline` to the liquid tag will render the css that would have been in the file.

```liquid
<style>
{% hyde_fonts inline %}
</style>
```

4. [Optional] Decap CMS

If you use Decap CMS, you can use the property `decap-config [levels-of-indent]`.
This will output yml formatted configuration that matches the fonts data file.

```yaml
# note that the top of the file needs frontmatter boundaries to
# process the file through Jekyll
---
---

...
collections:
  {% hyde_fonts decap-config 1 %}
  ...
```

which will render as

```yaml
collections:
  # Hyde Fonts ---
  - label: Hyde-Fonts
    name: fonts
    file: "_data/fonts.yml"
    fields:
      - label: Fonts
        name: fonts
        widget: object
        fields:
          - label: Faces
            name: faces
            widget: list
            collapsed: false
            create: true
            fields:
              - label: Name
                name: name
                widget: string
              - label: Weights
                name: weights
                widget: list
                collapsed: false
                fields:
                  - label: Weight
                    name: value
                    widget: string
                  - label: Italic
                    name: italic
                    widget: boolean
```

Configuration
-------------

Hyde Fonts comes with the following configuration. Override as necessary in your Jekyll Config

```yaml
# Default Configuration

hyde_fonts:
  data_source_name: fonts
  file_output_path: assets/fonts
  css_output_name: fonts.css
  css_minify: true
  enable: true
  fetch_fonts: true
  keep_files: true
```

`data_source_name`
: name of the data object in `site.config.data` when generating. This is usually the filename without extension.

`file_output_path`
: relative path from the root of your generated site to the location of the generated css files.

`css_output_name`
: filename to save font css as.

`css_minify`
: minify the css generated (reuses Jekyll's SASS compiler)

`enable`
: will download fonts and generate the css files when enabled, otherwise will skip the process at build time

`fetch_fonts`
: download fonts that don't exist locally

`keep_files`
: will not delete files between builds, and will reuse existing files if they match.

Create a font manifest in `_data/fonts.yml` which will be used to fetch the desired fonts.

The following example lists Montserrat and Roboto in various weights and italic styles, that will be fetched from Google Fonts and stored in the congiured path.

```yaml
fonts:
  faces:
    - name: Montserrat
      provider: google
      weights:
        - value: 200
          italic: false
        - value: 200
          italic: true
        - value: 400
          italic: false
        - value: 400
          italic: true
        - value: 600
          italic: false
        - value: 800
          italic: false
    - name: Roboto
      provider: google
      weights:
        - value: 200
          italic: false
        - value: 200
          italic: true
        - value: 400
          italic: false
        - value: 400
          italic: true
        - value: 600
          italic: false
        - value: 800
          italic: false
```

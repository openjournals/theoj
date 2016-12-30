# Remove Emcee compressor because it doesn't always work
# For example `var regex= /\/*abc;` is compressed with unintended consequences
Theoj::Application.assets.unregister_bundle_processor "text/html", :html_compressor

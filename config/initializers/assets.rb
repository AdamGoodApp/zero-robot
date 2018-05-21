assets = Rails.application.config.assets

assets.version = '1.0'

# Use Webpack generated manifest
assets.manifest = Rails.root.join('vendor', 'assets', 'sprockets-manifest.json')

# Don't check if precompiled (it's not)
assets.check_precompiled_asset = false

# Don't use any prefix (handled in manifest)
assets.prefix = '/'

# Change lookup folders for js/css
dir_map = ActionView::Helpers::AssetUrlHelper::ASSET_PUBLIC_DIRECTORIES
dir_map[:javascript] = '/js'
dir_map[:stylesheet] = '/css'

# Add fonts
assets.paths << Rails.root.join('vendor', 'assets', 'fonts')

# Disable precompilation
assets.compile = false
assets.precompile = []

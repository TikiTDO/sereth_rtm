module Sereth::AssetDependency
  def method_missing(name, *args, &block)
    match = /add_(.+)_dependency/.match(name)
    if match
      add_asset_dependency match[1], *args, &block
    else
      super
    end
  end

  def add_asset_dependency(type, asset_name, asset_base_url, asset_version = nil)
    get = "#{asset_base_url}#{asset_version}.#{type}"
    download_to = "vendor/assets/#{type.long}/vendor"
  end
end
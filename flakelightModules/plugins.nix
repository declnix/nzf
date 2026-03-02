{ config, flakelight, ... }:
{
  config.outputs.plugins = flakelight.importDirPaths (config.nixDir + "/plugins");
}

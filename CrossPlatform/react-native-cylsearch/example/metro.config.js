const path = require('path');
const { getDefaultConfig } = require('@react-native/metro-config');
const { withMetroConfig } = require('react-native-monorepo-config');

const root = path.resolve(__dirname, '..');

/**
 * Metro configuration
 * https://facebook.github.io/metro/docs/configuration
 *
 * @type {import('metro-config').MetroConfig}
 */
const config = withMetroConfig(getDefaultConfig(__dirname), {
  root,
  dirname: __dirname,
  // The libraries' TypeScript sources: this package, and CYLTabBarController's tab bar (vendor/, scripts/fetch-cyltabbar.sh).
  conditions: ['react-native-cylsearch-source', 'react-native-cyltabbar-source'],
});

// CYLTabBarController's tab bar is not part of this monorepo (vendor/, scripts/fetch-cyltabbar.sh): Metro reads its
// TypeScript sources directly instead of its unbuilt `lib/`.
const tabBar = path.resolve(__dirname, 'vendor/CYLTabBarController/CrossPlatform/react-native-cyltabbar');
config.watchFolders = [...(config.watchFolders || []), tabBar];
const resolveRequest = config.resolver.resolveRequest;
config.resolver.resolveRequest = (context, moduleName, platform) =>
  moduleName === 'react-native-cyltabbar'
    ? { type: 'sourceFile', filePath: path.join(tabBar, 'src', 'index.tsx') }
    : (resolveRequest || context.resolveRequest)(context, moduleName, platform);

module.exports = config;

/* eslint no-console:0 */

function importAll (r) {
  r.keys().forEach(r);
}

require('jquery-ujs');
require('hammerjs');

// should start looking for nodejs replacements
importAll(require.context('../vendor', true, /\.js$/));

importAll(require.context('../src/styles/base', true, /\.scss$/));

require("jquery-ui/ui/widgets/autocomplete");
require("jquery-ui/ui/widgets/button");
require("jquery-ui/ui/widgets/dialog");
require("jquery-ui/ui/widgets/draggable");
require("jquery-ui/ui/widgets/resizable");
require("jquery-ui/themes/base/core.css");
require("jquery-ui/themes/base/autocomplete.css");
require("jquery-ui/themes/base/button.css");
require("jquery-ui/themes/base/dialog.css");
require("jquery-ui/themes/base/draggable.css");
require("jquery-ui/themes/base/resizable.css");
require("jquery-ui/themes/base/theme.css");

importAll(require.context('../src/javascripts', true, /\.js(\.erb)?$/));
importAll(require.context('../src/styles/common', true, /\.scss(?:\.erb)?$/));
importAll(require.context('../src/styles/specific', true, /\.scss(?:\.erb)?$/));

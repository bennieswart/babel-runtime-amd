#!/bin/bash

rm -rf build dist
mkdir -p build/prep

cp -r node_modules/core-js node_modules/babel-runtime node_modules/regenerator-runtime build/prep

sed -i 's/define\( \|(\)/define2\1/g' build/prep/core-js/modules/es6.regexp.to-string.js
./node_modules/requirejs/bin/r.js -convert build/prep/core-js build/amd/core-js
./node_modules/requirejs/bin/r.js -convert build/prep/babel-runtime build/amd/babel-runtime
sed -i 's/symbol/symbol\/index/' build/amd/babel-runtime/core-js/symbol.js
mv build/amd/babel-runtime/regenerator{/index.js,.js}
./node_modules/requirejs/bin/r.js -convert build/prep/regenerator-runtime build/amd/regenerator-runtime
mv build/amd/regenerator-runtime{/runtime-module.js,.js}
sed -i 's/".\/runtime"/".\/regenerator-runtime\/runtime"/' build/amd/regenerator-runtime.js
sed -i 's/\(require(".\/regenerator-runtime\/runtime")\)/{default:\1}/' build/amd/regenerator-runtime.js

cat > build/amd/babel-polyfill.js << __EOF__
define(function(){
(function(global){
$(cat node_modules/babel-polyfill/lib/index.js)
})(typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {});
})
__EOF__

node makeconfig.js amd > build/r.amd.conf.js
./node_modules/requirejs/bin/r.js -o build/r.amd.conf.js

node makefiles.js

node makeconfig.js dist > build/r.dist.conf.js
./node_modules/requirejs/bin/r.js -o build/r.dist.conf.js

./node_modules/uglify-js/bin/uglifyjs -c passes=2 build/dist/bundle.js > build/dist/bundle.min.js

cp -r build/dist dist

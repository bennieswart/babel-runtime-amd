#!/bin/bash

rm -rf build dist
mkdir -p build/prep/@babel

cp -r node_modules/core-js node_modules/regenerator-runtime build/prep
cp -r node_modules/@babel/runtime build/prep/@babel
./node_modules/.bin/babel --config-file ./.babelrc -d build/prep/@babel/runtime/helpers/ build/prep/@babel/runtime/helpers/esm/*
rm -r build/prep/@babel/runtime/helpers/esm
sed -i 's/..\/..\/helpers\/esm/..\/helpers/' build/prep/@babel/runtime/helpers/*
sed -i 's/helpers\/esm/helpers/' build/prep/@babel/runtime/helpers/*
sed -i 's/(0, _typeof4.default)(\([^)]*\))/typeof \1/g' build/prep/@babel/runtime/helpers/typeof.js
sed -i '1 s/^.*$/define(["exports"], function(_exports) {/g' build/prep/@babel/runtime/helpers/typeof.js

sed -i 's/define\( \|(\)/define2\1/g' build/prep/core-js/modules/es6.regexp.to-string.js
./node_modules/requirejs/bin/r.js -convert build/prep/core-js build/amd/core-js
./node_modules/requirejs/bin/r.js -convert build/prep/@babel/runtime build/amd/@babel/runtime
mv build/amd/@babel/runtime/regenerator{/index.js,.js}
sed -i 's/..\/helpers/.\/helpers/' build/amd/@babel/runtime/regenerator.js
./node_modules/requirejs/bin/r.js -convert build/prep/regenerator-runtime build/amd/regenerator-runtime
mv build/amd/regenerator-runtime{/runtime-module.js,.js}
sed -i 's/".\/runtime"/".\/regenerator-runtime\/runtime"/' build/amd/regenerator-runtime.js

cat > build/amd/babel-polyfill.js << __EOF__
define(function(){
(function(global){
$(cat node_modules/babel-polyfill/lib/index.js)
})(typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {});
})
__EOF__

node makeconfig7.js amd > build/r.amd.conf.js
./node_modules/requirejs/bin/r.js -o build/r.amd.conf.js

node makefiles.js

node makeconfig7.js dist > build/r.dist.conf.js
./node_modules/requirejs/bin/r.js -o build/r.dist.conf.js

./node_modules/uglify-js/bin/uglifyjs -c passes=2 build/dist/bundle.js > build/dist/bundle.min.js

cp -r build/dist dist7

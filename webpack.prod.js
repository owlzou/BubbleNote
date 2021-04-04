const { merge } = require("webpack-merge");
const path = require("path");
const common = require("./webpack.common.js");

module.exports = merge(common, {
  mode: "production",

  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: {
          loader: "elm-webpack-loader",
          options: {
            optimize: true,
            files: [path.resolve(__dirname, "src/Main.elm")],
          },
        },
      },
    ],
  },
});

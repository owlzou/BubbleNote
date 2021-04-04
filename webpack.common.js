const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

module.exports = {
  entry: { main: ["./src/ts/main.ts"] },
  output: {
    filename: "js/[name].bundle.js",
    path: path.resolve(__dirname, "www"),
  },
  plugins: [
    new HtmlWebpackPlugin({
      filename: "index.html",
      template: "src/public/index.html",
    }),
    new MiniCssExtractPlugin({
      filename: "[name].css",
    }),
  ],
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        use: "ts-loader",
        exclude: /node_modules/,
      },
      {
        test: /\.css$/i,
        use: [MiniCssExtractPlugin.loader, "css-loader"],
      },
      {
        test: /\.styl$/,
        use: [MiniCssExtractPlugin.loader, "css-loader", "stylus-loader"], // compiles Styl to CSS
      },
      {
        //https://webpack.js.org/guides/asset-modules/
        test: /\.(ttf|jpg|png)$/,
        type: "asset/resource",
        generator: {
          filename: "assets/[name][ext]",
        },
      },
    ],
  },
  resolve: {
    extensions: [".tsx", ".ts", ".js"],
  },
};

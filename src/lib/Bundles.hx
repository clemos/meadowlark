package lib;

class Bundles
{
	public static var connectBundleOptions = {
		bundles: {
			clientJavaScript: {
				main: {
					file: '/js/meadowlark.min.js',
					location: 'beforeBodyClose',
					contents: [
						'/js/contact.js',
						'/js/cart.js',
					]
				}
			},
			clientCss: {
				main: {
					file: '/css/meadowlark.min.css',
					contents: [
						'/css/main.css',
						'/css/cart.css',
					]
				}
			}
		}
	}
}
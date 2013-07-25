unorm = require 'unorm'
module.exports =
	get: (req, res) ->
		if req.query?.text
			result = unorm.nfd(req.query.text).replace(/^\s\s*/, "").replace(/\s\s*/g, "-").replace(/&/g, "and")
			res.json 200, {slug: result}
		else
			res.json 404, "No text given in query string"
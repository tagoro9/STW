#Set up a routing four our homepage:
app.get '/', (req,res) ->
	res.render 'index', layout: false
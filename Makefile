default :
	bin/elm-make --yes --output public/index.html src/CircuitStatus.elm

deploy : default
	git push origin master
	bin/firebase deploy


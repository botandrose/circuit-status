default:
	elm make --yes --output public/index.html src/CircuitStatus.elm

deploy:
	firebase deploy


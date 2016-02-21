default:
	elm make --yes --output public/index.html Main.elm 

deploy:
	firebase deploy


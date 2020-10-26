build: ## Docker build
	docker build -t tsoftglobal/jenkins-biq-nodejs-agent .
	docker push tsoftglobal/jenkins-biq-nodejs-agent

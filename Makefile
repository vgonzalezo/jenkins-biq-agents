build: ## Docker build
	docker build -t tsoftglobal/jenkins-biq-nodejs-agent node14/.
	docker build -t tsoftglobal/jenkins-biq-java-agent java11/.
	
push:
	docker push tsoftglobal/jenkins-biq-nodejs-agent
	docker push tsoftglobal/jenkins-biq-java-agent

run: build push
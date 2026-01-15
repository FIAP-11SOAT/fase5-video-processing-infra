eks-update:
	aws eks update-kubeconfig --name fase3-infra-totem-de-pedidos-eks-cluster

tf-apply:
	cd deploy/terraform && terraform apply -auto-approve

tf-destroy:
	cd deploy/terraform && terraform destroy -auto-approve

tf-plan:
	cd deploy/terraform && terraform plan

elastic-apm-up:
	cd deploy/docker/elastic-apm && docker-compose up -d

elastic-apm-down:
	cd deploy/docker/elastic-apm && docker-compose down -v
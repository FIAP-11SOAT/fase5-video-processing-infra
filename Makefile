eks-update:
	aws eks update-kubeconfig --name fase5-video-processing-infra-eks-cluster

tf-apply:
	cd deploy/terraform && terraform apply -auto-approve

tf-destroy: clean-vpc-deps
	cd deploy/terraform && terraform destroy -auto-approve

# Remove security groups criados pelo Kubernetes ALB Controller (fora do Terraform)
# que ficam como dependencias orfas na VPC e bloqueiam o terraform destroy
clean-vpc-deps:
	@echo "Limpando dependencias orfas da VPC (SGs criados pelo ALB Controller)..."
	@VPC_ID=$$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=fase5-video-processing-infra-vpc" \
		--query 'Vpcs[0].VpcId' --output text 2>/dev/null); \
	if [ -n "$$VPC_ID" ] && [ "$$VPC_ID" != "None" ]; then \
		echo "VPC encontrada: $$VPC_ID"; \
		SG_IDS=$$(aws ec2 describe-security-groups \
			--filters "Name=vpc-id,Values=$$VPC_ID" \
			--query 'SecurityGroups[?GroupName!=`default`].GroupId' \
			--output text 2>/dev/null); \
		for SG in $$SG_IDS; do \
			echo "Removendo SG orfao: $$SG"; \
			aws ec2 delete-security-group --group-id $$SG 2>/dev/null || true; \
		done; \
	else \
		echo "VPC nao encontrada ou ja destruida, continuando..."; \
	fi

tf-plan:
	cd deploy/terraform && terraform plan

elastic-apm-up:
	cd deploy/docker/elastic-apm && docker-compose up -d

elastic-apm-down:
	cd deploy/docker/elastic-apm && docker-compose down -v
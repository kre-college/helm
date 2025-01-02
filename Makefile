.PHONY: index-repo
index-repo:
	helm repo index docs/ --url https://kre-college.github.io/helm/docs
	mv docs/index.yaml .

.PHONY:package-all
package-all:
	helm package charts/* --destination docs/
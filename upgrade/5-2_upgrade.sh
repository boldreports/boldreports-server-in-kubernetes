#!/usr/bin/env bash
# Copyright (c) Syncfusion Inc. All rights reserved.
#

while [ $# -gt 0 ]; do
  case "$1" in
    --version=*)
      version="${1#*=}"
      ;;
    --namespace=*)
      namespace="${1#*=}"
      ;;
    *)
  esac
  shift
done

[ -n "$version" ] || read -p 'Enter the version to upgrade: ' version

if [ -z "$version" ]
then
	echo "Version is empty."
else	
	if [ -z "$namespace" ]
	then
		namespace="default"
	fi
	
	kubectl set image deployment/id-web-deployment id-web-container=gcr.io/boldreports/bold-identity:$version --namespace=$namespace --record 
	kubectl set image deployment/id-api-deployment id-api-container=gcr.io/boldreports/bold-idp-api:$version --namespace=$namespace --record 
	kubectl set image deployment/id-ums-deployment id-ums-container=gcr.io/boldreports/bold-ums:$version --namespace=$namespace --record 
	kubectl set image deployment/reports-web-deployment reports-web-container=gcr.io/boldreports/boldreports-server:$version --namespace=$namespace --record 
	kubectl set image deployment/reports-api-deployment reports-api-container=gcr.io/boldreports/boldreports-server-api:$version --namespace=$namespace --record 
	kubectl set image deployment/reports-jobs-deployment reports-jobs-container=gcr.io/boldreports/boldreports-server-jobs:$version --namespace=$namespace --record 
	kubectl set image deployment/reports-reportservice-deployment reports-reportservice-container=gcr.io/boldreports/boldreports-designer:$version --namespace=$namespace --record 
	kubectl set image deployment/reports-viewer-deployment reports-viewer-container=gcr.io/boldreports/boldreports-viewer:$version --namespace=$namespace --record 
	kubectl set image deployment/reports-export-deployment reports-export-container=gcr.io/boldreports/boldreports-export:$version --namespace=$namespace --record 
fi

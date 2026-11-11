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
	
	kubectl set image deployment/id-web-deployment id-web-container=syncfusion/bold-identity:$version --namespace=$namespace --record 
	kubectl set image deployment/id-api-deployment id-api-container=syncfusion/bold-idp-api:$version --namespace=$namespace --record 
	kubectl set image deployment/id-ums-deployment id-ums-container=syncfusion/bold-ums:$version --namespace=$namespace --record 
	kubectl set image deployment/reports-web-deployment reports-web-container=syncfusion/boldreports-server:$version --namespace=$namespace --record 
	kubectl set image deployment/reports-api-deployment reports-api-container=syncfusion/boldreports-server-api:$version --namespace=$namespace --record 
	kubectl set image deployment/reports-jobs-deployment reports-jobs-container=syncfusion/boldreports-server-jobs:$version --namespace=$namespace --record 
	kubectl set image deployment/reports-reportservice-deployment reports-reportservice-container=syncfusion/boldreports-designer:$version --namespace=$namespace --record 
	kubectl set image deployment/reports-viewer-deployment reports-viewer-container=syncfusion/boldreports-viewer:$version --namespace=$namespace --record
	kubectl set image deployment/bold-etl-deployment bold-etl-container=syncfusion/bold-etl:$version --namespace=$namespace --record
	kubectl set image deployment/reports-ai-deployment reports-ai-container=syncfusion/boldreports-ai:$version --namespace=$namespace --record
	kubectl set image deployment/reports-mcp-deployment reports-mcp-container=syncfusion/boldreports-mcp-server:$version --namespace=$namespace --record
	kubectl set image deployment/reports-export-deployment reports-export-container=syncfusion/boldreports-export:$version --namespace=$namespace --record
fi

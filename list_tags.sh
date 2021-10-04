#!/bin/sh
aws ecr list-images --repository-name petclinic --output text | awk '{print $3}' | sort -r

#!/bin/bash
set -e

APP_NAME=$1
IMAGE=$2
MANIFEST_TEMPLATE=$3

echo "Starting Blue-Green deployment for $APP_NAME"

# Find active color by looking at the service selector
ACTIVE_COLOR=$(kubectl get svc ${APP_NAME}-service -o=jsonpath='{.spec.selector.color}' 2>/dev/null || echo "none")

if [ "$ACTIVE_COLOR" == "blue" ]; then
    NEW_COLOR="green"
    OLD_COLOR="blue"
elif [ "$ACTIVE_COLOR" == "green" ]; then
    NEW_COLOR="blue"
    OLD_COLOR="green"
else
    # First deployment
    NEW_COLOR="blue"
    OLD_COLOR="none"
fi

echo "Current active color: $ACTIVE_COLOR"
echo "Deploying $APP_NAME to $NEW_COLOR environment..."

# Generate new deployment manifest from template
sed -e "s|IMAGE_PLACEHOLDER|$IMAGE|g" \
    -e "s|COLOR_PLACEHOLDER|$NEW_COLOR|g" \
    $MANIFEST_TEMPLATE > ./.deploy-${APP_NAME}.yaml

# Apply new deployment
kubectl apply -f ./.deploy-${APP_NAME}.yaml

# Wait for the new deployment to be ready
echo "Waiting for deployment/${APP_NAME}-deployment-${NEW_COLOR} to be ready..."
kubectl rollout status deployment/${APP_NAME}-deployment-${NEW_COLOR} --timeout=120s

# Patch service to point to new color
echo "Switching traffic to $NEW_COLOR environment..."
kubectl patch service ${APP_NAME}-service -p "{\"spec\":{\"selector\":{\"color\":\"${NEW_COLOR}\"}}}"

echo "Successfully switched traffic to $NEW_COLOR environment."

# Scale down the old deployment to save resources (optional, but good for saving cost)
if [ "$OLD_COLOR" != "none" ]; then
    echo "Scaling down old $OLD_COLOR deployment..."
    kubectl scale deployment ${APP_NAME}-deployment-${OLD_COLOR} --replicas=0
fi

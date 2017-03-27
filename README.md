# k8s-ingress-repro
Repro for https://github.com/kubernetes/ingress/issues/489

## Setup

```shell
# Start minikube
minukube start --memory 4096

# Deploy ingress
kubectl apply -f ingress/default-backend.yml
kubectl apply -f ingress/controller.yml

# Build and push backend image
docker build -t foxylion/k8s-ingress-repro:backend backend
docker push foxylion/k8s-ingress-repro:backend

# Deploy backend
kubectl apply -f backend/backend.yml

# Add hosts entry
echo "`minikube ip` backend.local" | sudo tee -a /etc/hosts

# Test if running
curl http://backend.local:31234
```

## Results

JMeter keep-alive configuration can be found in "Thread Group -> HTTP Request -> Use Keep-Alive".

### Re-Reploy backend

#### without keep-alive

- Does not work without a preStop hook
- Does not work with `command: ["sleep", "1"]`
- Works with preStop `command: ["/bin/sh", "-c", "rm /usr/share/nginx/html/ready.json && sleep 10"]`

#### with keep-alive

*Assuming preStop `command: ["/bin/sh", "-c", "rm /usr/share/nginx/html/ready.json && sleep 10"]` should work.*

- Does not work with default JMeter configuration
- Does work with `http.connection.stalecheck$Boolean=true` in `httpclient.parameters` of JMeter

#### Optimizations

- Check if `sleep 10` can be further reduced, may interfere with `periodSeconds` of `readinessProbe`.

### Re-Deploy ingress controller

#### without keep-alive

- Does not work without a preStop hook

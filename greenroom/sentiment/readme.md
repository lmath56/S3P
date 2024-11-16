# Sentiment Service Scaling Setup

The below shows how to configure the Sentient service in a Google Kubernetes Engine cluster.

> [!NOTE] 
> These steps include steps that require access to the `greenroom_sentiment` repository.
> This is a private reposiory for a commercial product.   

## Requirements:
- **Google Cloud SDK**: Ensure you have the Google Cloud SDK installed and configured.
- **Terraform**: Install Terraform on your local machine.
- **kubectl**: Install `kubectl` to interact with your GKE cluster.
- **GCP Project**: A Google Cloud Platform project with billing enabled.
- **Access to the greenroom_sentiment repostory**: This is a private repository
- **[Helm](https://helm.sh/docs/intro/install/) (Optional)**: To monitor the Kubernetes cluster

## Deploying on GKE with Terraform

To deploy the sentiment analysis service on GKE using Terraform, follow these steps:

1. **Build and Push Image**

    First clone the greenroom_sentiment repository. Note that this is a private respository. 

    ```bash
    git clone <repository-url>.git
    cd <repostory>
    ```

    Then build and push to an existing container repository, which will need to be set up as per the [guide here](https://cloud.google.com/artifact-registry/docs/repositories/create-repos#create-console)
    ```bash
    docker build . -t sentiment
    
    docker tag sentiment europe-west3-docker.pkg.dev/optimal-carving-438111-h3/s3p-gcp-k8s/greenroom-sentiment:latest
    
    docker push europe-west3-docker.pkg.dev/optimal-carving-438111-h3/s3p-gcp-k8s/greenroom-sentiment:latest
    ```

2. **Initialise Terraform** 

    Now that the image has been pushed, return to this repository

    Initialise, and deploy all the Google Cloud Platform infrastructure with Terraform. These services are defined in the `infra.tf` file.

    ```sh
    terraform init
    terraform apply
    ```

2. **Deploy the Application**: Once the GKE cluster is up and running, use `kubectl` to deploy the sentiment analysis application.
    
    First make sure `kubectl` is configured to work with the GKE cluster:

    ```bash
    gcloud container clusters get-credentials greenroom-sentiment-cluster --region europe-west4-a
    ```

    Then deploy the workloads and services:

    ```sh
    kubectl apply -f deployment.yaml
    ```

3. **Set up Grafana for Monitoring (Optional)**

    Deploy the Kubernetes Metrics Server

    ```bash
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    ```

    Then deploy Prometheus and Grafana
    ```bash
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update
    helm install prometheus prometheus-community/prometheus --set server.service.type=LoadBalancer
    helm install grafana grafana/grafana --set service.type=LoadBalancer
    ```

    Get the access IPs of Prometheus and Grafana with the below

    ```bash
    kubectl get svc
    ``` 

    You will see the Extrernal IP for both `grafana` and `prometheus-server`


    Prometheus should be configured to scrape metrics from the Kubernetes API server, kubelets, and other components. The default Prometheus Helm chart already includes configurations for scraping Kubernetes metrics.

## Grafana Setup

### Retrieve Grafana Credentials

To retrieve the Grafana credentials using bash:
```bash
kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode
```

To retrieve these credentials using Powershell:

```powershell
# Get the base64-encoded password
$encodedPassword = kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}"

# Decode the password
$decodedPassword = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encodedPassword))

# Output the decoded password
Write-Output $decodedPassword
```

### Configure Grafana

1. Log in to Grafana: Use the username admin and the retrieved password to log in to Grafana.
2. Add Prometheus Data Source to Grafana:
    1. In Grafana, go to Connections > Data Sources.
    2. Click Add data source.
    3. Select Prometheus.
    4. Set the URL to the Prometheus server's external IP address (e.g., ``http://<PROMETHEUS_EXTERNAL_IP>``).
    5. Click Save & Test.

#### Import Kubernetes Dashboards

1. In Grafana, go to Create > Import.
2. You can import pre-built Kubernetes dashboards from the Grafana dashboard repository. For example, you can use the Kubernetes cluster monitoring dashboard with [https://grafana.com/grafana/dashboards/315](https://grafana.com/grafana/dashboards/315)
3. Enter the dashboard ID `315` and click Load.
4. Select the Prometheus data source you added earlier and click Import.


Some dashboards can be found [here](https://github.com/dotdc/grafana-dashboards-kubernetes) which were made by [David Calvert](https://github.com/dotdc)

| Dashboard                          | ID    |
|:-----------------------------------|:------|
| k8s-addons-prometheus.json         | 19105 |
| k8s-addons-trivy-operator.json     | 16337 |
| k8s-system-api-server.json         | 15761 |
| k8s-system-coredns.json            | 15762 |
| **k8s-views-global.json**          | **15757** |
| k8s-views-namespaces.json          | 15758 |
| **k8s-views-nodes.json**           | **15759** |
| **k8s-views-pods.json**            | **15760** |